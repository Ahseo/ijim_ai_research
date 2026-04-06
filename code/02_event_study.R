################################################################################
# 02_event_study.R
# US-003: Event-Study / 동적 DID (GO/NO-GO 관문)
# 대응: R1-3A, C2 — 사전 추세 검증
# 참고: Angrist & Pischke (2009), Autor (2003)
################################################################################
library(data.table)
library(dplyr)
library(fixest)    # 빠른 고정효과 추정
library(ggplot2)
library(cowplot)

cat("=== US-003: Event-Study / 동적 DID ===\n")
setwd("/Users/gujaeseo/Documents/projects/yeonseo/ijim_ai_research")
dir.create("output/figures", showWarnings = FALSE, recursive = TRUE)
dir.create("output/tables", showWarnings = FALSE, recursive = TRUE)
dir.create("output/interpretation", showWarnings = FALSE, recursive = TRUE)

################################################################################
# 1. 데이터 로드 & 주차 변수 생성
################################################################################
cat("[1/5] 데이터 로드...\n")

# 매칭 전 전체 데이터 사용 (매칭 데이터는 표본이 작아 event-study에 부적합할 수 있음)
data_day <- fread("data/processed/data_day_full.csv")

# AI 도입일
AI_DATE <- as.Date("2020-10-26")

# 주차 변수 생성: 도입일 기준 상대 주차
data_day[, ymd := as.Date(ymd)]
data_day[, rel_day := as.numeric(ymd - AI_DATE)]
data_day[, rel_week := floor(rel_day / 7)]

# 주차 분포 확인
cat("  상대 주차 범위:", min(data_day$rel_week), "~", max(data_day$rel_week), "\n")
cat("  주차별 관측수:\n")
print(data_day[, .N, by = rel_week][order(rel_week)])

# 기준 주차: -1 (도입 직전 주)
data_day[, rel_week_factor := relevel(factor(rel_week), ref = "-1")]

# station_date
data_day[, station_date := paste(management_partner_id, ymd, sep = "_")]

################################################################################
# 2. Event-Study 추정: 전체 평균 효과
################################################################################
cat("\n[2/5] Event-Study 추정 (전체)...\n")

# fixest의 i() 함수 사용 — 자동으로 기준 기간 처리
# Y = orders_per_hour
# FE: rider_id, station_date
# Cluster: rider_id

es_avg <- feols(orders_per_hour ~ i(rel_week, Treat, ref = -1) |
                  rider_id + station_date,
                data = data_day, cluster = ~rider_id)

cat("  추정 완료. 계수 수:", length(coef(es_avg)), "\n")
summary_es <- as.data.frame(coef(summary(es_avg)))
cat("  사전 기간 계수:\n")
print(summary_es[grepl("rel_week::-", rownames(summary_es)), ])

################################################################################
# 3. 사전 추세 검증 (F-test)
################################################################################
cat("\n[3/5] 사전 추세 F-검정...\n")

# 사전 기간 계수 이름 추출
pre_coefs <- rownames(summary_es)[grepl("rel_week::-", rownames(summary_es))]
# -1은 기준 기간이므로 제외 (이미 제외됨)
pre_coefs <- pre_coefs[pre_coefs != "rel_week::-1:Treat"]

if (length(pre_coefs) > 0) {
  # Wald test: 사전 기간 계수가 결합적으로 0인지
  f_test <- wald(es_avg, pre_coefs)
  cat("  F-검정 통계량:", f_test$stat, "\n")
  cat("  p-value:", f_test$p, "\n")
  cat("  판단:", ifelse(f_test$p > 0.10, "✅ PASS (p > 0.10) — 병행 추세 지지",
                        "❌ FAIL (p ≤ 0.10) — 사전 추세 위반 가능"), "\n")

  # 개별 계수 유의성
  cat("\n  개별 사전 계수 (5% 유의):\n")
  es_ct <- coeftable(es_avg)
  for (pc in pre_coefs) {
    if (pc %in% rownames(es_ct)) {
      est <- es_ct[pc, 1]
      pv <- es_ct[pc, 4]
      sig <- ifelse(pv < 0.05, "*** 유의!", "비유의")
      cat("    ", pc, ": ", round(est, 4), " (p=", round(pv, 4), ") ", sig, "\n")
    }
  }
} else {
  cat("  사전 기간 계수 없음 (데이터 기간 확인 필요)\n")
}

################################################################################
# 4. Event-Study 플롯
################################################################################
cat("\n[4/5] Event-Study 플롯 생성...\n")

# iplot 데이터 추출
es_ct <- coeftable(es_avg)
es_coefs <- data.frame(
  estimate = es_ct[, 1],
  se = es_ct[, 2],
  pval = es_ct[, ncol(es_ct)],
  term = rownames(es_ct)
)
es_coefs$week <- as.numeric(gsub("rel_week::(-?\\d+):Treat", "\\1", es_coefs$term))
es_coefs <- es_coefs[!is.na(es_coefs$week), ]
es_coefs$ci_lo <- es_coefs$estimate - 1.96 * es_coefs$se
es_coefs$ci_hi <- es_coefs$estimate + 1.96 * es_coefs$se

# 기준 기간 (-1) 추가
ref_row <- data.frame(estimate = 0, se = 0, pval = 1,
                      term = "ref", week = -1, ci_lo = 0, ci_hi = 0)
es_coefs <- rbind(es_coefs, ref_row)
es_coefs <- es_coefs[order(es_coefs$week), ]

# 플롯
p <- ggplot(es_coefs, aes(x = week, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "red", linewidth = 0.8) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "steelblue") +
  geom_point(size = 2.5, color = "steelblue") +
  geom_line(color = "steelblue", linewidth = 0.6) +
  labs(x = "AI 도입 대비 상대 주차",
       y = "처리 효과 (시간당 주문 수)",
       title = "Event-Study: AI 도입이 일일 생산성에 미치는 동적 효과",
       subtitle = "기준 주차 = -1 (도입 직전 주). 빨간 점선 = AI 도입 시점") +
  annotate("text", x = min(es_coefs$week) + 0.5, y = max(es_coefs$ci_hi) * 0.9,
           label = "← 도입 전 (Pre)", hjust = 0, size = 3.5, color = "gray40") +
  annotate("text", x = 0.5, y = max(es_coefs$ci_hi) * 0.9,
           label = "도입 후 (Post) →", hjust = 0, size = 3.5, color = "gray40") +
  theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank())

ggsave("output/figures/event_study_productivity.png", p, width = 10, height = 6, dpi = 300)
cat("  저장: output/figures/event_study_productivity.png\n")

# 계수 표 저장
fwrite(es_coefs[, c("week", "estimate", "se", "pval", "ci_lo", "ci_hi")],
       "output/tables/event_study_coefficients.csv")

################################################################################
# 5. 결과 해석 저장
################################################################################
cat("\n[5/5] 결과 해석 저장...\n")

# GO/NO-GO 판단
go_nogo <- if (exists("f_test") && f_test$p > 0.10) "GO" else "NEEDS_REVIEW"

interpretation <- paste0(
  "# Event-Study 분석 결과 해석\n\n",
  "## 대응 리뷰어 지적: R1-3A, C2\n\n",
  "## 방법론\n",
  "- 모형: 동적 DID (fixest::feols)\n",
  "- 종속변수: orders_per_hour (시간당 주문 수)\n",
  "- 고정효과: rider_id, station_date (지점×날짜)\n",
  "- 군집 표준오차: rider_id 수준\n",
  "- 기준 기간: 도입 직전 주 (rel_week = -1)\n",
  "- 참고: Angrist & Pischke (2009) Mostly Harmless Econometrics; Sun & Abraham (2021) 동적 DID\n\n",
  "## 사전 추세 검증\n",
  if (exists("f_test")) {
    paste0("- 결합 F-검정 통계량: ", round(f_test$stat, 3), "\n",
           "- p-value: ", round(f_test$p, 4), "\n",
           "- 판단: ", ifelse(f_test$p > 0.10, "병행 추세 가정 지지 (p > 0.10)", "사전 추세 위반 가능 (p ≤ 0.10)"), "\n")
  } else "- F-검정 미실행\n",
  "\n## GO/NO-GO 판단: ", go_nogo, "\n\n",
  "## 코드\n- code/02_event_study.R\n\n",
  "## 산출물\n",
  "- output/figures/event_study_productivity.png\n",
  "- output/tables/event_study_coefficients.csv\n"
)

writeLines(interpretation, "output/interpretation/01-event-study.md")
cat("  저장: output/interpretation/01-event-study.md\n")

cat("\n=== Event-Study 완료. GO/NO-GO:", go_nogo, "===\n")
