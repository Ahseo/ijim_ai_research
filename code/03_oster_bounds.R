################################################################################
# 03_oster_bounds.R
# US-004: Oster (2019) Bounds — 비관측 선택 편의 민감도
# 대응: R1-3C, R2-7
# 참고: Oster, E. (2019). Unobservable Selection and Coefficient Stability.
#        Journal of Business & Economic Statistics, 37(2), 187-204.
################################################################################
library(data.table)
library(fixest)
library(sensemakr)

cat("=== US-004: Oster Bounds ===\n")
setwd("/Users/gujaeseo/Documents/projects/yeonseo/ijim_ai_research")

data_day <- fread("data/processed/data_day_full.csv")
data_day[, after_treat := after * Treat]
data_day[, station_date := paste(management_partner_id, ymd, sep = "_")]

# sensemakr는 lm 객체 필요. FE 대신 demean 후 OLS 사용.
# 방법: Oster 공식 직접 구현

cat("[1/3] 비통제 회귀 (통제변수 없이)...\n")
mod_short <- lm(orders_per_hour ~ after_treat, data = data_day)
beta_short <- coef(mod_short)["after_treat"]
r2_short <- summary(mod_short)$r.squared

cat("[2/3] 통제 회귀 (관측 가능한 통제변수 포함)...\n")
mod_long <- lm(orders_per_hour ~ after_treat + Treat + after +
                 factor(management_partner_id) + factor(ymd),
               data = data_day)
beta_long <- coef(mod_long)["after_treat"]
r2_long <- summary(mod_long)$r.squared

cat("  beta_short:", round(beta_short, 4), " R2_short:", round(r2_short, 4), "\n")
cat("  beta_long:", round(beta_long, 4), " R2_long:", round(r2_long, 4), "\n")

cat("[3/3] Oster δ* 계산...\n")
# R_max = min(1, 1.3 * R2_long) — Oster (2019) 권장
r2_max <- min(1, 1.3 * r2_long)

# δ* = [beta_long * (R_max - R2_long)] / [(beta_short - beta_long) * (R2_long - R2_short)]
numerator <- beta_long * (r2_max - r2_long)
denominator <- (beta_short - beta_long) * (r2_long - r2_short)

if (abs(denominator) > 1e-10) {
  delta_star <- numerator / denominator
} else {
  delta_star <- Inf
  cat("  주의: 분모 ≈ 0 (통제변수 추가 시 계수 변화 거의 없음)\n")
}

cat("\n=== 결과 ===\n")
cat("  R_max:", round(r2_max, 4), "\n")
cat("  δ*:", round(delta_star, 4), "\n")
cat("  해석:", ifelse(abs(delta_star) > 1,
    "✅ 강건 — 비관측 선택이 관측 변수의 |δ*|배 이상이어야 효과를 무효화",
    "⚠️ 주의 — 비관측 선택에 민감할 수 있음"), "\n")

# 결과 저장
results <- data.frame(
  beta_short = beta_short,
  r2_short = r2_short,
  beta_long = beta_long,
  r2_long = r2_long,
  r2_max = r2_max,
  delta_star = delta_star,
  robust = abs(delta_star) > 1
)
fwrite(results, "output/tables/oster_bounds.csv")

# 해석 저장
interpretation <- paste0(
  "# Oster (2019) Bounds 분석 결과\n\n",
  "## 대응 리뷰어 지적: R1-3C, R2-7\n\n",
  "## 방법론\n",
  "- Oster, E. (2019). Unobservable Selection and Coefficient Stability. JBES, 37(2), 187-204.\n",
  "- R_max = min(1, 1.3 × R²_long) = ", round(r2_max, 4), "\n",
  "- δ* = β_long × (R_max - R²_long) / [(β_short - β_long) × (R²_long - R²_short)]\n\n",
  "## 결과\n",
  "- β (비통제): ", round(beta_short, 4), " (R² = ", round(r2_short, 4), ")\n",
  "- β (통제): ", round(beta_long, 4), " (R² = ", round(r2_long, 4), ")\n",
  "- δ* = ", round(delta_star, 4), "\n",
  "- 판단: ", ifelse(abs(delta_star) > 1, "강건 (|δ*| > 1)", "주의 필요 (|δ*| ≤ 1)"), "\n\n",
  "## 코드: code/03_oster_bounds.R\n",
  "## 산출물: output/tables/oster_bounds.csv\n"
)
writeLines(interpretation, "output/interpretation/02-oster-bounds.md")
cat("완료.\n")
