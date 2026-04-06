################################################################################
# 02_event_study_extended.R
# 확장 Event-Study: new_data.csv로 사후 기간 3개월까지 확장
# 대응: R1-3A, C2, C6(짧은 관찰 기간)
################################################################################
library(data.table)
library(fixest)
library(ggplot2)

cat("=== Event-Study 확장: 사후 3개월 ===\n")
setwd("/Users/gujaeseo/Documents/projects/yeonseo/ijim_ai_research")

################################################################################
# 1. 확장 데이터 생성 (9/26 ~ 1/31)
################################################################################
cat("[1/4] 확장 데이터 로드...\n")

# 두 데이터 합치기 (부산만)
d1 <- fread("data/riders_full.csv")
setnames(d1, c("submittedat","assignedat","pickedupat","deliveredat","agent_id","agent_fee","agent_extra_fee","distorigintodest"),
         c("submitted_at","assigned_at","picked_up_at","delivered_at","rider_id","rider_fee","rider_extra_fee","distance"), skip_absent=TRUE)

d2 <- fread("data/new_data.csv")
setnames(d2, c("agent_id","agent_fee","agent_extra_fee","monitoring_partner_id"),
         c("rider_id","rider_fee","rider_extra_fee","monitoringpartner_id"), skip_absent=TRUE)

common <- intersect(names(d1), names(d2))
d_all <- rbind(d1[, ..common], d2[, ..common])
rm(d1, d2); gc()
d_all <- d_all[!duplicated(order_id)]

# 부산 필터
rider_info <- fread("data/rider_info.csv")
busan_ids <- unique(rider_info[grepl("부산", management_partner_name) & !grepl("울산|진해", management_partner_name), management_partner_id])
d_busan <- d_all[management_partner_id %in% busan_ids]
rm(d_all); gc()

d_busan[, submitted_at := as.POSIXct(submitted_at, tz="UTC")]
d_busan[, assigned_at := as.POSIXct(assigned_at, tz="UTC")]
d_busan[, picked_up_at := as.POSIXct(picked_up_at, tz="UTC")]
d_busan[, delivered_at := as.POSIXct(delivered_at, tz="UTC")]
d_busan <- d_busan[!is.na(picked_up_at) & !is.na(delivered_at)]
d_busan[, ymd := as.Date(submitted_at)]
d_busan[, rider_total_fee := rider_fee + rider_extra_fee]
d_busan <- d_busan[rider_total_fee > 0]

# 확장 기간: 2020-09-01 ~ 2021-01-31
AI_DATE <- as.Date("2020-10-26")
d_ext <- d_busan[ymd >= as.Date("2020-09-01") & ymd <= as.Date("2021-01-31")]
d_ext[, after := ifelse(ymd >= AI_DATE, 1L, 0L)]

# Treatment
treat_riders <- unique(d_ext[is_rec_assigned == 1, rider_id])
d_ext[, Treat := ifelse(rider_id %in% treat_riders, 1L, 0L)]

cat("  확장 기간 주문:", nrow(d_ext), "행,", uniqueN(d_ext$rider_id), "라이더\n")
cat("  기간:", as.character(min(d_ext$ymd)), "~", as.character(max(d_ext$ymd)), "\n")

# Shift 정의
setorder(d_ext, rider_id, ymd, assigned_at)
d_ext[, delivered_at_num := as.numeric(delivered_at)]
d_ext[, delivered_at_cummax := cummax(delivered_at_num), by=.(ymd, rider_id)]
d_ext[, delivered_at_max := as.POSIXct(delivered_at_cummax, origin="1970-01-01", tz="UTC")]
func_check <- function(a, d) { n <- length(a); if(n==1) return(1L); c(1L, ifelse(a[-1] <= d[-n], 1L, 0L)) }
d_ext[, check := func_check(assigned_at, delivered_at_max), by=.(ymd, rider_id)]
d_ext[, shift := cumsum(check == 0L) + 1L, by=.(ymd, rider_id)]

# Shift → Day 집계
data_shift_ext <- d_ext[, .(
  num_orders = .N, shift_profit = sum(rider_total_fee),
  start = assigned_at[1], finish = max(delivered_at),
  total_duration = as.numeric(difftime(max(delivered_at), assigned_at[1], units="mins"))
), by=.(rider_id, Treat, management_partner_id, ymd, after, shift)]

data_day_ext <- data_shift_ext[, .(
  total_shift = .N, total_orders = sum(num_orders), total_fee = sum(shift_profit),
  working_duration = sum(total_duration) / 60
), by=.(rider_id, Treat, management_partner_id, ymd, after)]
data_day_ext[, total_labor := working_duration]
data_day_ext[, orders_per_hour := total_orders / total_labor]

# Proficiency (도입 전 기준)
prof <- data_day_ext[after == 0, .(prof = mean(orders_per_hour, na.rm=TRUE)), by=rider_id]
data_day_ext <- merge(data_day_ext, prof, by="rider_id", all.x=TRUE)
data_day_ext <- data_day_ext[!is.na(prof)]

cat("  확장 day 데이터:", nrow(data_day_ext), "행,", uniqueN(data_day_ext$rider_id), "라이더\n")

################################################################################
# 2. 확장 Event-Study 추정
################################################################################
cat("[2/4] 확장 Event-Study 추정...\n")

data_day_ext[, rel_week := floor(as.numeric(as.Date(ymd) - AI_DATE) / 7)]
data_day_ext[, station_date := paste(management_partner_id, ymd, sep="_")]

cat("  주차 범위:", min(data_day_ext$rel_week), "~", max(data_day_ext$rel_week), "\n")

es <- feols(orders_per_hour ~ i(rel_week, Treat, ref = -1) | rider_id + station_date,
            data = data_day_ext, cluster = ~rider_id)

################################################################################
# 3. 결과 추출 & F-검정
################################################################################
cat("[3/4] 결과 추출...\n")

ct <- coeftable(es)
weeks <- as.numeric(sub("rel_week::([^:]+):Treat", "\\1", rownames(ct)))
es_coefs <- data.frame(week = weeks, estimate = ct[,1], se = ct[,2], pval = ct[,ncol(ct)], row.names = NULL)
es_coefs$ci_lo <- es_coefs$estimate - 1.96 * es_coefs$se
es_coefs$ci_hi <- es_coefs$estimate + 1.96 * es_coefs$se
ref <- data.frame(week=-1, estimate=0, se=0, pval=1, ci_lo=0, ci_hi=0)
es_coefs <- rbind(es_coefs, ref)
es_coefs <- es_coefs[order(es_coefs$week), ]

# F-test on pre-treatment
pre_names <- rownames(ct)[grepl("rel_week::-", rownames(ct))]
if (length(pre_names) > 0) {
  f_test <- wald(es, pre_names)
  cat("  사전 추세 F-검정: F=", round(f_test$stat, 3), ", p=", round(f_test$p, 4), "\n")
  cat("  판단:", ifelse(f_test$p > 0.10, "PASS", "FAIL"), "\n")
}

# 사후 주차별 효과
post_coefs <- es_coefs[es_coefs$week >= 0, ]
cat("\n  사후 주차별 효과:\n")
print(post_coefs[, c("week", "estimate", "pval")])

fwrite(es_coefs, "output/tables/event_study_extended.csv")

################################################################################
# 4. 플롯
################################################################################
cat("[4/4] 플롯 생성...\n")

p <- ggplot(es_coefs, aes(x = week, y = estimate, group = 1)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "red", linewidth = 0.8) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "steelblue") +
  geom_point(size = 2.5, color = "steelblue") +
  geom_line(color = "steelblue", linewidth = 0.6) +
  scale_x_continuous(breaks = seq(min(es_coefs$week), max(es_coefs$week), 2)) +
  labs(x = "Weeks Relative to AI Introduction",
       y = "Treatment Effect (Orders per Hour)",
       title = "Extended Event-Study: AI Effects over 3+ Months Post-Introduction",
       subtitle = "Reference = Week -1. Red line = AI introduction. 95% CI shown.") +
  theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank())

ggsave("output/figures/event_study_extended.png", p, width = 12, height = 6, dpi = 300)

# 해석 저장
interp <- paste0(
  "# Extended Event-Study (3+ Months Post-Treatment)\n\n",
  "## 대응: R1-3A, C2, C6 (짧은 관찰 기간)\n\n",
  "## 핵심 개선\n",
  "- 기존: 사전 4주 + 사후 4주 (1개월)\n",
  "- 확장: 사전 ~8주 + 사후 ~14주 (3.5개월)\n",
  "- new_data.csv 추가로 2020-12, 2021-01 포함\n\n",
  "## 결과\n",
  "- 사전 추세 F-검정: F=", round(f_test$stat, 3), ", p=", round(f_test$p, 4), "\n",
  "- 판단: ", ifelse(f_test$p > 0.10, "병행 추세 지지", "주의 필요"), "\n",
  "- 사후 효과 추세: 장기적으로 효과가 ",
  ifelse(cor(post_coefs$week, post_coefs$estimate) > 0, "증가", "감소/변동"), "\n\n",
  "## 코드: code/02_event_study_extended.R\n",
  "## 산출물: output/tables/event_study_extended.csv, output/figures/event_study_extended.png\n"
)
writeLines(interp, "output/interpretation/01b-event-study-extended.md")

cat("\n=== 확장 Event-Study 완료 ===\n")
