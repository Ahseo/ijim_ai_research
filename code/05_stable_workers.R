################################################################################
# 05_stable_workers.R
# US-006: 안정 근로자 하위표본 분석
# 대응: R1-3C, R2-7
################################################################################
library(data.table)
library(fixest)

cat("=== US-006: 안정 근로자 하위표본 ===\n")
setwd("/Users/gujaeseo/Documents/projects/yeonseo/ijim_ai_research")

data_day <- fread("data/processed/data_day_full.csv")
data_day[, station_date := paste(management_partner_id, ymd, sep = "_")]
data_day[, after_treat := after * Treat]

cat("[1/3] 안정 근로자 식별...\n")
# 라이더별 도입 전/후 근무 패턴 비교
rider_pattern <- data_day[, .(
  mean_labor = mean(total_labor, na.rm = TRUE),
  sd_labor = sd(total_labor, na.rm = TRUE),
  mean_orders = mean(total_orders, na.rm = TRUE),
  sd_orders = sd(total_orders, na.rm = TRUE),
  n_days = .N
), by = .(rider_id, after)]

# wide 형태로
pre <- rider_pattern[after == 0, .(rider_id, pre_labor = mean_labor, pre_sd_labor = sd_labor,
                                    pre_orders = mean_orders, pre_days = n_days)]
post <- rider_pattern[after == 1, .(rider_id, post_labor = mean_labor,
                                     post_orders = mean_orders, post_days = n_days)]
pattern <- merge(pre, post, by = "rider_id")

# 안정 기준: 도입 전후 평균 근무시간 변화가 ±1 SD 이내
pattern[, labor_change := abs(post_labor - pre_labor)]
pattern[, stable := labor_change <= pre_sd_labor]
# SD가 NA인 경우 (1일만 근무) 제외
pattern[is.na(stable), stable := FALSE]

n_stable <- sum(pattern$stable)
n_total <- nrow(pattern)
cat("  안정 근로자:", n_stable, "/", n_total, "(", round(100 * n_stable / n_total, 1), "%)\n")

stable_riders <- pattern[stable == TRUE]$rider_id
data_stable <- data_day[rider_id %in% stable_riders]

cat("[2/3] 하위표본 DID 추정...\n")
# 전체 표본 DID (비교용)
mod_full <- feols(orders_per_hour ~ after_treat | rider_id + station_date,
                  data = data_day, cluster = ~rider_id)
# 안정 근로자 DID
mod_stable <- feols(orders_per_hour ~ after_treat | rider_id + station_date,
                    data = data_stable, cluster = ~rider_id)

ct_full <- coeftable(mod_full)
ct_stable <- coeftable(mod_stable)

cat("  전체 표본: β =", round(ct_full[1, 1], 4), "(SE =", round(ct_full[1, 2], 4), ")\n")
cat("  안정 표본: β =", round(ct_stable[1, 1], 4), "(SE =", round(ct_stable[1, 2], 4), ")\n")

# 일관성 확인: 안정 표본 추정치가 전체 표본 95% CI 내에 있는지
full_ci_lo <- ct_full[1, 1] - 1.96 * ct_full[1, 2]
full_ci_hi <- ct_full[1, 1] + 1.96 * ct_full[1, 2]
consistent <- ct_stable[1, 1] >= full_ci_lo & ct_stable[1, 1] <= full_ci_hi
cat("  전체 표본 95% CI: [", round(full_ci_lo, 4), ",", round(full_ci_hi, 4), "]\n")
cat("  안정 표본 추정치가 CI 내:", ifelse(consistent, "✅ 일관적", "❌ 불일관"), "\n")

cat("[3/3] 결과 저장...\n")
results <- data.frame(
  sample = c("full", "stable"),
  n_riders = c(uniqueN(data_day$rider_id), length(stable_riders)),
  n_obs = c(nrow(data_day), nrow(data_stable)),
  coef = c(ct_full[1, 1], ct_stable[1, 1]),
  se = c(ct_full[1, 2], ct_stable[1, 2]),
  pval = c(ct_full[1, ncol(ct_full)], ct_stable[1, ncol(ct_stable)])
)
fwrite(results, "output/tables/stable_workers.csv")

interpretation <- paste0(
  "# 안정 근로자 하위표본 분석 결과\n\n",
  "## 대응: R1-3C, R2-7\n\n",
  "## 안정 기준: 도입 전후 평균 근무시간 변화가 ±1 SD 이내\n",
  "- 안정 근로자: ", n_stable, "/", n_total, " (", round(100 * n_stable / n_total, 1), "%)\n\n",
  "## 결과\n",
  "- 전체: β = ", round(ct_full[1,1], 4), " (SE = ", round(ct_full[1,2], 4), ")\n",
  "- 안정: β = ", round(ct_stable[1,1], 4), " (SE = ", round(ct_stable[1,2], 4), ")\n",
  "- 일관성: ", ifelse(consistent, "안정 표본 추정치가 전체 95% CI 내", "불일관"), "\n\n",
  "## 코드: code/05_stable_workers.R\n",
  "## 산출물: output/tables/stable_workers.csv\n"
)
writeLines(interpretation, "output/interpretation/04-stable-workers.md")
cat("완료.\n")
