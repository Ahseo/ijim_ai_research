################################################################################
# 07_learning_dynamics.R
# US-008: 기간 내 학습 역학
# 대응: R2-9
################################################################################
library(data.table)
library(fixest)

cat("=== US-008: 기간 내 학습 역학 ===\n")
setwd("/Users/gujaeseo/Documents/projects/yeonseo/ijim_ai_research")

data_day <- fread("data/processed/data_day_full.csv")
data_day[, ymd := as.Date(ymd)]
data_day[, station_date := paste(management_partner_id, ymd, sep = "_")]

AI_DATE <- as.Date("2020-10-26")

cat("[1/2] 사후 기간 주차별 효과 추정...\n")
# 사후 기간만 주차 변수
data_day[, post_week := ifelse(after == 1, floor(as.numeric(ymd - AI_DATE) / 7) + 1, 0L)]
data_day[post_week < 0, post_week := 0L]

cat("  사후 주차 분포:\n")
print(table(data_day$post_week))

# 주차별 Treat 효과
data_day[, treat_w1 := Treat * as.integer(post_week == 1)]
data_day[, treat_w2 := Treat * as.integer(post_week == 2)]
data_day[, treat_w3 := Treat * as.integer(post_week == 3)]
data_day[, treat_w4 := Treat * as.integer(post_week == 4)]

mod <- feols(orders_per_hour ~ treat_w1 + treat_w2 + treat_w3 + treat_w4 |
               rider_id + station_date,
             data = data_day, cluster = ~rider_id)

ct <- coeftable(mod)
cat("\n  주차별 처리 효과:\n")
results <- data.frame(
  post_week = 1:4,
  coef = ct[1:4, 1],
  se = ct[1:4, 2],
  pval = ct[1:4, ncol(ct)]
)
print(results)

fwrite(results, "output/tables/learning_dynamics.csv")

cat("[2/2] 학습 효과 판단...\n")
# 효과가 시간에 따라 증가하면 학습 지지
trend <- cor(results$post_week, results$coef)
learning <- trend > 0.3
cat("  시간-효과 상관:", round(trend, 3), "\n")
cat("  판단:", ifelse(learning, "✅ 학습 효과 시사 (효과 증가 추세)",
                      "ℹ️ 뚜렷한 학습 추세 없음"), "\n")

interpretation <- paste0(
  "# 기간 내 학습 역학 분석 결과\n\n",
  "## 대응: R2-9\n\n",
  "## 방법론: 사후 기간 주차별 처리 효과 추정\n",
  "- 모형: Y = Σ β_w(Treat × Week_w) + FE + ε\n",
  "- FE: rider_id, station_date. Cluster: rider_id\n\n",
  "## 결과\n",
  "- Week 1: β = ", round(results$coef[1], 4), " (p = ", round(results$pval[1], 4), ")\n",
  "- Week 2: β = ", round(results$coef[2], 4), " (p = ", round(results$pval[2], 4), ")\n",
  "- Week 3: β = ", round(results$coef[3], 4), " (p = ", round(results$pval[3], 4), ")\n",
  "- Week 4: β = ", round(results$coef[4], 4), " (p = ", round(results$pval[4], 4), ")\n",
  "- 시간-효과 상관: ", round(trend, 3), "\n",
  "- 판단: ", ifelse(learning, "학습 효과 시사", "뚜렷한 학습 추세 없음"), "\n\n",
  "## 코드: code/07_learning_dynamics.R\n",
  "## 산출물: output/tables/learning_dynamics.csv\n"
)
writeLines(interpretation, "output/interpretation/06-learning-dynamics.md")
cat("완료.\n")
