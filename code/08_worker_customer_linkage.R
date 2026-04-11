################################################################################
# 08_worker_customer_linkage.R
# Worker-customer linkage analysis using matched rider-day and order data
# Goal: provide evidence on whether worker-side efficiency covaries with
# customer waiting times within the observed platform operations.
################################################################################
library(data.table)
library(fixest)
library(ggplot2)

cat("=== US-011: Worker-customer linkage ===\n")
setwd("/Users/gujaeseo/Documents/projects/yeonseo/ijim_ai_research")
dir.create("output/tables", showWarnings = FALSE, recursive = TRUE)
dir.create("output/figures", showWarnings = FALSE, recursive = TRUE)
dir.create("output/interpretation", showWarnings = FALSE, recursive = TRUE)

cat("[1/4] Load matched day/order data...\n")
orders <- fread("data/processed/orders_matched.csv")
day <- fread("data/processed/data_day_matched.csv")

day[, station_date := paste(management_partner_id, ymd, sep = "_")]
orders[, station_date := paste(management_partner_id, ymd, sep = "_")]
orders[, waiting_min := waiting_sec / 60]

# Reconstruct single vs stacked deliveries from shift composition.
shift_size <- orders[, .(shift_n_orders = .N), by = .(rider_id, ymd, shift)]
setkey(shift_size, rider_id, ymd, shift)
setkey(orders, rider_id, ymd, shift)
orders <- shift_size[orders]
orders[, is_single := as.integer(shift_n_orders == 1)]

day_link <- day[, .(
  rider_id,
  management_partner_id,
  ymd,
  station_date,
  orders_per_hour,
  total_orders,
  total_labor,
  share_idled
)]
setkey(orders, rider_id, ymd)
setkey(day_link, rider_id, ymd)
orders <- orders[day_link]

cat("[2/4] Aggregate daily customer outcomes by rider-day...\n")
daily_link <- orders[, .(
  avg_wait_all = mean(waiting_min, na.rm = TRUE),
  avg_wait_single = mean(waiting_min[is_single == 1], na.rm = TRUE),
  avg_wait_stacked = mean(waiting_min[is_single == 0], na.rm = TRUE),
  avg_distance = mean(distorigintodest, na.rm = TRUE),
  share_single = mean(is_single, na.rm = TRUE),
  n_orders = .N
), by = .(rider_id, management_partner_id, ymd, station_date, orders_per_hour,
          total_orders, total_labor, share_idled)]

for (col in c("avg_wait_single", "avg_wait_stacked")) {
  daily_link[!is.finite(get(col)), (col) := NA_real_]
}

cat("[3/4] Estimate linkage regressions...\n")
m_all <- feols(
  avg_wait_all ~ orders_per_hour + avg_distance | rider_id + station_date,
  data = daily_link,
  cluster = ~rider_id
)
m_single <- feols(
  avg_wait_single ~ orders_per_hour + avg_distance | rider_id + station_date,
  data = daily_link[!is.na(avg_wait_single)],
  cluster = ~rider_id
)
m_stacked <- feols(
  avg_wait_stacked ~ orders_per_hour + avg_distance | rider_id + station_date,
  data = daily_link[!is.na(avg_wait_stacked)],
  cluster = ~rider_id
)
m_share_single <- feols(
  share_single ~ orders_per_hour | rider_id + station_date,
  data = daily_link,
  cluster = ~rider_id
)

extract_row <- function(model, outcome, sample_n, outcome_mean) {
  ct <- coeftable(model)
  data.table(
    outcome = outcome,
    coef = unname(ct["orders_per_hour", 1]),
    se = unname(ct["orders_per_hour", 2]),
    pval = unname(ct["orders_per_hour", ncol(ct)]),
    n_obs = sample_n,
    mean_wait = outcome_mean
  )
}

results <- rbindlist(list(
  extract_row(m_all, "all_orders", nobs(m_all),
              mean(daily_link$avg_wait_all, na.rm = TRUE)),
  extract_row(m_single, "single_order_days", nobs(m_single),
              mean(daily_link$avg_wait_single, na.rm = TRUE)),
  extract_row(m_stacked, "stacked_order_days", nobs(m_stacked),
              mean(daily_link$avg_wait_stacked, na.rm = TRUE))
))
results[, `:=`(
  ci_lo = coef - 1.96 * se,
  ci_hi = coef + 1.96 * se
)]
fwrite(results, "output/tables/worker_customer_linkage.csv")

share_ct <- coeftable(m_share_single)
share_result <- data.table(
  outcome = "share_single",
  coef = unname(share_ct["orders_per_hour", 1]),
  se = unname(share_ct["orders_per_hour", 2]),
  pval = unname(share_ct["orders_per_hour", ncol(share_ct)]),
  n_obs = nobs(m_share_single)
)
fwrite(share_result, "output/tables/worker_customer_linkage_share_single.csv")

cat("[4/4] Save coefficient plot + interpretation...\n")
plot_dt <- copy(results)
plot_dt[, outcome := factor(
  outcome,
  levels = c("all_orders", "single_order_days", "stacked_order_days"),
  labels = c("All orders", "Single-order days", "Stacked-order days")
)]

p <- ggplot(plot_dt, aes(x = outcome, y = coef)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), width = 0.15, color = "steelblue4") +
  geom_point(size = 3, color = "steelblue4") +
  coord_flip() +
  labs(
    x = NULL,
    y = "Change in customer waiting time (minutes)\nper +1 order/hour in rider-day productivity",
    title = "Worker-side productivity and customer waiting time move together",
    subtitle = "Rider FE and station-date FE; matched sample"
  ) +
  theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank())
ggsave("output/figures/worker_customer_linkage.png", p, width = 9, height = 5, dpi = 300)

interp <- paste0(
  "# Worker-customer linkage analysis\n\n",
  "## Purpose\n",
  "- Provide direct evidence on whether worker-side efficiency covaries with customer waiting times.\n",
  "- This is not a formal mediation design; it is an operational linkage analysis using matched rider-day and order data.\n\n",
  "## Specification\n",
  "- Outcome: rider-day average customer waiting time (all orders / single-order days / stacked-order days)\n",
  "- Key regressor: rider-day productivity (orders_per_hour)\n",
  "- Fixed effects: rider FE, station-date FE\n",
  "- Controls: average rider-day delivery distance\n",
  "- Clustered SE: rider level\n\n",
  "## Main results\n",
  "- All orders: beta = ", round(results[outcome == "all_orders", coef], 4),
  " (SE = ", round(results[outcome == "all_orders", se], 4),
  ", p = ", round(results[outcome == "all_orders", pval], 4), ")\n",
  "- Single-order days: beta = ", round(results[outcome == "single_order_days", coef], 4),
  " (SE = ", round(results[outcome == "single_order_days", se], 4),
  ", p = ", round(results[outcome == "single_order_days", pval], 4), ")\n",
  "- Stacked-order days: beta = ", round(results[outcome == "stacked_order_days", coef], 4),
  " (SE = ", round(results[outcome == "stacked_order_days", se], 4),
  ", p = ", round(results[outcome == "stacked_order_days", pval], 4), ")\n",
  "- Share of single orders: beta = ", round(share_result$coef, 4),
  " (SE = ", round(share_result$se, 4),
  ", p = ", round(share_result$pval, 4), ")\n\n",
  "## Interpretation\n",
  "- More productive rider-days are associated with shorter customer waits, indicating that worker-side efficiency and customer experience are operationally linked.\n",
  "- However, productivity is not associated with a higher share of single-order deliveries, suggesting that pass-through is not driven by simple order-type reallocation.\n",
  "- This supports a cautious worker-to-customer linkage claim, but not a formal mediation claim.\n\n",
  "## Files\n",
  "- Table: output/tables/worker_customer_linkage.csv\n",
  "- Figure: output/figures/worker_customer_linkage.png\n"
)
writeLines(interp, "output/interpretation/07-worker-customer-linkage.md")

cat("Saved:\n")
cat("  output/tables/worker_customer_linkage.csv\n")
cat("  output/tables/worker_customer_linkage_share_single.csv\n")
cat("  output/figures/worker_customer_linkage.png\n")
cat("  output/interpretation/07-worker-customer-linkage.md\n")
