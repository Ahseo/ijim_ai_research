################################################################################
# 06_inequality.R
# US-007: Gini/Theil 불평등 분해
# 대응: R1-M2
################################################################################
library(data.table)
library(ggplot2)

cat("=== US-007: Gini/Theil 불평등 지표 ===\n")
setwd("/Users/gujaeseo/Documents/projects/yeonseo/ijim_ai_research")

data_day <- fread("data/processed/data_day_full.csv")

# Gini 계수 계산 함수
gini <- function(x) {
  x <- x[!is.na(x) & x > 0]
  n <- length(x)
  if (n < 2) return(NA)
  x <- sort(x)
  2 * sum((1:n) * x) / (n * sum(x)) - (n + 1) / n
}

# Theil 지수 계산 함수
theil <- function(x) {
  x <- x[!is.na(x) & x > 0]
  n <- length(x)
  if (n < 2) return(NA)
  mu <- mean(x)
  mean((x / mu) * log(x / mu))
}

# P90/P10, P75/P25 비율
p_ratio <- function(x, hi = 0.9, lo = 0.1) {
  x <- x[!is.na(x) & x > 0]
  quantile(x, hi) / quantile(x, lo)
}

cat("[1/3] 불평등 지표 산출...\n")

# 라이더별 기간 평균 생산성
rider_prod <- data_day[, .(avg_oph = mean(orders_per_hour, na.rm = TRUE)),
                       by = .(rider_id, Treat, after)]

# 4개 그룹: Treat x After
groups <- rider_prod[, .(
  gini = gini(avg_oph),
  theil = theil(avg_oph),
  p90_p10 = p_ratio(avg_oph, 0.9, 0.1),
  p75_p25 = p_ratio(avg_oph, 0.75, 0.25),
  mean_prod = mean(avg_oph),
  sd_prod = sd(avg_oph),
  n_riders = .N
), by = .(Treat, after)]

groups[, period := ifelse(after == 0, "도입 전", "도입 후")]
groups[, group := ifelse(Treat == 1, "AI 채택자", "비채택자")]

cat("  결과:\n")
print(groups[, .(group, period, gini = round(gini, 4), theil = round(theil, 4),
                 p90_p10 = round(p90_p10, 2), mean_prod = round(mean_prod, 2), n_riders)])

# 전체 불평등 (Treat 무관)
overall <- rider_prod[, .(
  gini = gini(avg_oph),
  theil = theil(avg_oph),
  p90_p10 = p_ratio(avg_oph, 0.9, 0.1),
  p75_p25 = p_ratio(avg_oph, 0.75, 0.25)
), by = after]
overall[, period := ifelse(after == 0, "도입 전", "도입 후")]
cat("\n  전체 불평등:\n")
print(overall[, .(period, gini = round(gini, 4), theil = round(theil, 4), p90_p10 = round(p90_p10, 2))])

fwrite(groups, "output/tables/inequality_metrics.csv")
fwrite(overall, "output/tables/inequality_overall.csv")

cat("[2/3] 플롯 생성...\n")
# 생산성 분포 밀도 플롯
plot_data <- rider_prod[, .(rider_id, avg_oph, period = ifelse(after == 0, "도입 전", "도입 후"))]
p <- ggplot(plot_data, aes(x = avg_oph, fill = period)) +
  geom_density(alpha = 0.4) +
  labs(x = "평균 시간당 주문 수", y = "밀도",
       title = "AI 도입 전후 생산성 분포 변화",
       fill = "기간") +
  theme_minimal(base_size = 12) +
  scale_fill_manual(values = c("도입 전" = "gray60", "도입 후" = "steelblue"))
ggsave("output/figures/inequality_density.png", p, width = 8, height = 5, dpi = 300)

cat("[3/3] 해석 저장...\n")
gini_change <- overall[after == 1]$gini - overall[after == 0]$gini
interpretation <- paste0(
  "# Gini/Theil 불평등 분해 결과\n\n",
  "## 대응: R1-M2\n\n",
  "## 방법론: Gini 계수, Theil 지수, P90/P10 비율\n\n",
  "## 결과\n",
  "- 전체 Gini 변화: ", round(overall[after == 0]$gini, 4), " → ",
    round(overall[after == 1]$gini, 4), " (Δ = ", round(gini_change, 4), ")\n",
  "- ", ifelse(gini_change < 0, "불평등 감소", "불평등 증가/유지"), "\n\n",
  "## 코드: code/06_inequality.R\n",
  "## 산출물: output/tables/inequality_metrics.csv, output/figures/inequality_density.png\n"
)
writeLines(interpretation, "output/interpretation/05-inequality.md")
cat("완료.\n")
