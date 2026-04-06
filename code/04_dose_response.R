################################################################################
# 04_dose_response.R
# US-005: 처리 강도 / 용량-반응 분석
# 대응: R1-3B
################################################################################
library(data.table)
library(fixest)
library(ggplot2)

cat("=== US-005: 처리 강도 / 용량-반응 ===\n")
setwd("/Users/gujaeseo/Documents/projects/yeonseo/ijim_ai_research")

data_day <- fread("data/processed/data_day_full.csv")
orders <- fread("data/processed/orders_matched.csv",
                select = c("rider_id", "ymd", "after", "is_rec_assigned"))

cat("[1/4] AIShare 변수 구성...\n")
# 사후 기간 라이더별 AI 사용 비율
ai_share <- orders[after == 1, .(
  ai_orders = sum(is_rec_assigned),
  total_orders = .N,
  ai_share = mean(is_rec_assigned)
), by = rider_id]

cat("  AI 사용 비율 분포:\n")
print(summary(ai_share$ai_share))

# 사분위 생성
ai_share[, ai_quartile := cut(ai_share,
  breaks = c(-Inf, quantile(ai_share[ai_share > 0], probs = c(0.33, 0.67), na.rm = TRUE), Inf),
  labels = c("Q1_low", "Q2_mid", "Q3_high"),
  include.lowest = TRUE)]
# 비사용자는 Q0
ai_share[ai_share == 0, ai_quartile := "Q0_none"]
cat("  사분위 분포:\n")
print(table(ai_share$ai_quartile))

# merge
data_day <- merge(data_day, ai_share[, .(rider_id, ai_share, ai_quartile)],
                  by = "rider_id", all.x = TRUE)
data_day[is.na(ai_share), ai_share := 0]
data_day[is.na(ai_quartile), ai_quartile := "Q0_none"]
data_day[, station_date := paste(management_partner_id, ymd, sep = "_")]

cat("[2/4] 연속형 용량-반응 추정...\n")
data_day[, after_aishare := after * ai_share]
mod_cont <- feols(orders_per_hour ~ after_aishare | rider_id + station_date,
                  data = data_day, cluster = ~rider_id)
cat("  연속형 β:", round(coef(mod_cont)["after_aishare"], 4), "\n")

cat("[3/4] 사분위별 처리 효과 추정...\n")
data_day[, after_q1 := after * as.integer(ai_quartile == "Q1_low")]
data_day[, after_q2 := after * as.integer(ai_quartile == "Q2_mid")]
data_day[, after_q3 := after * as.integer(ai_quartile == "Q3_high")]

mod_quart <- feols(orders_per_hour ~ after_q1 + after_q2 + after_q3 |
                     rider_id + station_date,
                   data = data_day, cluster = ~rider_id)

ct <- coeftable(mod_quart)
quart_results <- data.frame(
  quartile = c("Q0_none (ref)", "Q1_low", "Q2_mid", "Q3_high"),
  coef = c(0, ct[, 1]),
  se = c(0, ct[, 2]),
  pval = c(NA, ct[, ncol(ct)])
)
fwrite(quart_results, "output/tables/dose_response_quartiles.csv")
cat("  Q1:", round(quart_results$coef[2], 4), "(p=", round(quart_results$pval[2], 4), ")\n")
cat("  Q2:", round(quart_results$coef[3], 4), "(p=", round(quart_results$pval[3], 4), ")\n")
cat("  Q3:", round(quart_results$coef[4], 4), "(p=", round(quart_results$pval[4], 4), ")\n")

# 단조성 검정
monotonic <- quart_results$coef[2] <= quart_results$coef[3] &
             quart_results$coef[3] <= quart_results$coef[4]
cat("  단조성:", ifelse(monotonic, "✅ 단조 증가", "❌ 비단조"), "\n")

cat("[4/4] 플롯 생성...\n")
p <- ggplot(quart_results[-1, ], aes(x = quartile, y = coef)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_point(size = 3, color = "steelblue") +
  geom_errorbar(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
                width = 0.2, color = "steelblue") +
  labs(x = "AI 사용 강도 그룹", y = "처리 효과 (시간당 주문 수)",
       title = "용량-반응: AI 사용 강도별 생산성 효과") +
  theme_minimal(base_size = 12)
ggsave("output/figures/dose_response.png", p, width = 8, height = 5, dpi = 300)

# 해석 저장
interpretation <- paste0(
  "# 용량-반응 분석 결과\n\n",
  "## 대응: R1-3B\n\n",
  "## 방법론\n",
  "- AIShare = (AI 배정 주문) / (사후 전체 주문) per rider\n",
  "- 연속형 + 사분위 구간 명세\n",
  "- FE: rider_id, station_date. Cluster: rider_id\n\n",
  "## 결과\n",
  "- 연속형 β: ", round(coef(mod_cont)["after_aishare"], 4), "\n",
  "- Q1(low): ", round(quart_results$coef[2], 4), "\n",
  "- Q2(mid): ", round(quart_results$coef[3], 4), "\n",
  "- Q3(high): ", round(quart_results$coef[4], 4), "\n",
  "- 단조성: ", ifelse(monotonic, "단조 증가 확인", "비단조"), "\n\n",
  "## 코드: code/04_dose_response.R\n",
  "## 산출물: output/tables/dose_response_quartiles.csv, output/figures/dose_response.png\n"
)
writeLines(interpretation, "output/interpretation/03-dose-response.md")
cat("완료.\n")
