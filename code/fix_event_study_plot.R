library(data.table); library(fixest); library(ggplot2)
setwd("/Users/gujaeseo/Documents/projects/yeonseo/ijim_ai_research")

data_day <- fread("data/processed/data_day_full.csv")
data_day[, ymd := as.Date(ymd)]
AI_DATE <- as.Date("2020-10-26")
data_day[, rel_week := floor(as.numeric(ymd - AI_DATE) / 7)]
data_day[, station_date := paste(management_partner_id, ymd, sep = "_")]

es_avg <- feols(orders_per_hour ~ i(rel_week, Treat, ref = -1) |
                  rider_id + station_date,
                data = data_day, cluster = ~rider_id)

ct <- coeftable(es_avg)
rn <- rownames(ct)

# week number extraction
weeks <- as.numeric(sub("rel_week::([^:]+):Treat", "\\1", rn))

es_coefs <- data.frame(
  week = weeks,
  estimate = ct[, 1],
  se = ct[, 2],
  pval = ct[, ncol(ct)],
  row.names = NULL
)
es_coefs$ci_lo <- es_coefs$estimate - 1.96 * es_coefs$se
es_coefs$ci_hi <- es_coefs$estimate + 1.96 * es_coefs$se

# add reference period
ref <- data.frame(week = -1, estimate = 0, se = 0, pval = 1, ci_lo = 0, ci_hi = 0)
es_coefs <- rbind(es_coefs, ref)
es_coefs <- es_coefs[order(es_coefs$week), ]

cat("Data for plot:\n")
print(es_coefs)

p <- ggplot(es_coefs, aes(x = week, y = estimate, group = 1)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "red", linewidth = 0.8) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "steelblue") +
  geom_point(size = 2.5, color = "steelblue") +
  geom_line(color = "steelblue", linewidth = 0.6) +
  scale_x_continuous(breaks = seq(-5, 4, 1)) +
  labs(x = "Weeks Relative to AI Introduction",
       y = "Treatment Effect (Orders per Hour)",
       title = "Event-Study: Dynamic Effects of AI on Daily Productivity",
       subtitle = "Reference = Week -1. Red dotted line = AI introduction. 95% CI shown.") +
  theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank())

ggsave("output/figures/event_study_productivity.png", p, width = 10, height = 6, dpi = 300)
cat("\nDone.\n")
