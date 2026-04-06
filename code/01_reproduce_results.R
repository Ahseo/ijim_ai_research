################################################################################
# 01_reproduce_results.R
# US-002: 논문 Table 4-7 재현 검증
# 대응: Phase 0 — 데이터-코드 정합성 확인
################################################################################
library(data.table)
library(dplyr)
library(lfe)

cat("=== US-002: 기존 결과 재현 검증 ===\n")
setwd("/Users/gujaeseo/Documents/projects/yeonseo/ijim_ai_research")
dir.create("output/tables", showWarnings = FALSE, recursive = TRUE)

# 데이터 로드
data_day <- fread("data/processed/data_day_matched.csv")
data_shift <- fread("data/processed/data_shift_matched.csv")

cat("Matched day data:", nrow(data_day), "행,", uniqueN(data_day$rider_id), "라이더\n")
cat("Matched shift data:", nrow(data_shift), "행\n")

# station_date 변수
data_day[, station_date := paste(management_partner_id, ymd, sep = "_")]
data_shift[, station_date := paste(management_partner_id, ymd, sep = "_")]

################################################################################
# Table 4: AI impact on daily productivity (DID + DDD)
################################################################################
cat("\n--- Table 4: 일일 생산성 DID/DDD ---\n")

# Column 1: DID — Average effect
# Y = orders_per_hour, Treatment = Treat × After
did_prod <- felm(orders_per_hour ~ Treat:after | rider_id + station_date | 0 | rider_id,
                 data = data_day)
cat("DID (Treat×After):", round(coef(did_prod)["Treat:after"], 4),
    "  SE:", round(summary(did_prod)$coef["Treat:after", "Cluster s.e."], 4),
    "  p:", round(summary(did_prod)$coef["Treat:after", "Pr(>|t|)"], 4), "\n")

# Column 2: DDD — By proficiency
# prof_high를 기준 그룹으로 사용 (논문과 동일)
data_day[, after_treat := after * Treat]
data_day[, after_treat_low := after * Treat * prof_low]
data_day[, after_treat_med := after * Treat * prof_med]
data_day[, after_treat_high := after * Treat * prof_high]
data_day[, after_low := after * prof_low]
data_day[, after_med := after * prof_med]

ddd_prod <- felm(orders_per_hour ~ after_treat + after_treat_low + after_treat_med +
                   after_low + after_med |
                   rider_id + station_date | 0 | rider_id,
                 data = data_day)
cat("DDD base (high):", round(coef(ddd_prod)["after_treat"], 4), "\n")
cat("DDD diff low:", round(coef(ddd_prod)["after_treat_low"], 4), "\n")
cat("DDD diff med:", round(coef(ddd_prod)["after_treat_med"], 4), "\n")

# 저장
t4_results <- data.frame(
  model = c("DID_avg", "DDD_base_high", "DDD_diff_low", "DDD_diff_med"),
  coef = c(coef(did_prod)["Treat:after"],
           coef(ddd_prod)["after_treat"],
           coef(ddd_prod)["after_treat_low"],
           coef(ddd_prod)["after_treat_med"]),
  se = c(summary(did_prod)$coef["Treat:after", "Cluster s.e."],
         summary(ddd_prod)$coef["after_treat", "Cluster s.e."],
         summary(ddd_prod)$coef["after_treat_low", "Cluster s.e."],
         summary(ddd_prod)$coef["after_treat_med", "Cluster s.e."]),
  pval = c(summary(did_prod)$coef["Treat:after", "Pr(>|t|)"],
           summary(ddd_prod)$coef["after_treat", "Pr(>|t|)"],
           summary(ddd_prod)$coef["after_treat_low", "Pr(>|t|)"],
           summary(ddd_prod)$coef["after_treat_med", "Pr(>|t|)"])
)
t4_results$sig <- ifelse(t4_results$pval < 0.01, "***",
                  ifelse(t4_results$pval < 0.05, "**",
                  ifelse(t4_results$pval < 0.1, "*", "")))
fwrite(t4_results, "output/tables/table4_daily_productivity.csv")
cat("\n논문 Table 4 비교:\n")
cat("  논문: DID avg ≈ +0.13 (3%), Med ≈ +0.25 (5%)\n")
cat("  재현: DID avg =", round(t4_results$coef[1], 4), ", Med =", round(t4_results$coef[3], 4), "\n")

################################################################################
# Table 5: AI impact on stack-level working behavior
################################################################################
cat("\n--- Table 5: 스택 수준 행동 ---\n")

# hourDOW가 없으면 생성
if (!"hourDOW" %in% names(data_shift)) {
  data_shift[, start_hour := hour(as.POSIXct(start))]
  data_shift[, wday_num := wday(as.Date(ymd))]
  data_shift[, hourDOW := paste(start_hour, wday_num, sep = "_")]
}

# Col 1: num_orders (orders per shift)
did_numorders <- felm(num_orders ~ Treat:after | rider_id + station_date + hourDOW | 0 | rider_id,
                      data = data_shift)

# Col 2: total_duration (shift duration)
did_duration <- felm(total_duration ~ Treat:after | rider_id + station_date + hourDOW | 0 | rider_id,
                     data = data_shift)

# Col 3: avg_duration_orders (time per order)
did_avgdur <- felm(avg_duration_orders ~ Treat:after | rider_id + station_date + hourDOW | 0 | rider_id,
                   data = data_shift)

# Col 4: idle_btw_shifts
did_idle <- felm(idle_btw_shifts ~ Treat:after | rider_id + station_date + hourDOW | 0 | rider_id,
                 data = data_shift[!is.na(idle_btw_shifts)])

t5_results <- data.frame(
  variable = c("num_orders", "total_duration", "avg_duration_orders", "idle_btw_shifts"),
  coef = c(coef(did_numorders)["Treat:after"], coef(did_duration)["Treat:after"],
           coef(did_avgdur)["Treat:after"], coef(did_idle)["Treat:after"]),
  se = c(summary(did_numorders)$coef["Treat:after", "Cluster s.e."],
         summary(did_duration)$coef["Treat:after", "Cluster s.e."],
         summary(did_avgdur)$coef["Treat:after", "Cluster s.e."],
         summary(did_idle)$coef["Treat:after", "Cluster s.e."]),
  pval = c(summary(did_numorders)$coef["Treat:after", "Pr(>|t|)"],
           summary(did_duration)$coef["Treat:after", "Pr(>|t|)"],
           summary(did_avgdur)$coef["Treat:after", "Pr(>|t|)"],
           summary(did_idle)$coef["Treat:after", "Pr(>|t|)"])
)
fwrite(t5_results, "output/tables/table5_shift_behavior.csv")
cat("  num_orders:", round(t5_results$coef[1], 4), " (p=", round(t5_results$pval[1], 4), ")\n")
cat("  total_duration:", round(t5_results$coef[2], 4), " (p=", round(t5_results$pval[2], 4), ")\n")
cat("  avg_dur_orders:", round(t5_results$coef[3], 4), " (p=", round(t5_results$pval[3], 4), ")\n")
cat("  idle_btw_shifts:", round(t5_results$coef[4], 4), " (p=", round(t5_results$pval[4], 4), ")\n")

################################################################################
# Table 6: AI impact on day-level working behavior
################################################################################
cat("\n--- Table 6: 일 수준 행동 ---\n")

did_shifts <- felm(total_shift ~ Treat:after | rider_id + station_date | 0 | rider_id, data = data_day)
did_orders <- felm(total_orders ~ Treat:after | rider_id + station_date | 0 | rider_id, data = data_day)
did_fee <- felm(total_fee ~ Treat:after | rider_id + station_date | 0 | rider_id, data = data_day)
did_labor <- felm(total_labor ~ Treat:after | rider_id + station_date | 0 | rider_id, data = data_day)

t6_results <- data.frame(
  variable = c("total_shift", "total_orders", "total_fee", "total_labor"),
  coef = c(coef(did_shifts)["Treat:after"], coef(did_orders)["Treat:after"],
           coef(did_fee)["Treat:after"], coef(did_labor)["Treat:after"]),
  se = c(summary(did_shifts)$coef["Treat:after", "Cluster s.e."],
         summary(did_orders)$coef["Treat:after", "Cluster s.e."],
         summary(did_fee)$coef["Treat:after", "Cluster s.e."],
         summary(did_labor)$coef["Treat:after", "Cluster s.e."]),
  pval = c(summary(did_shifts)$coef["Treat:after", "Pr(>|t|)"],
           summary(did_orders)$coef["Treat:after", "Pr(>|t|)"],
           summary(did_fee)$coef["Treat:after", "Pr(>|t|)"],
           summary(did_labor)$coef["Treat:after", "Pr(>|t|)"])
)
fwrite(t6_results, "output/tables/table6_day_behavior.csv")
cat("  total_shift:", round(t6_results$coef[1], 4), "\n")
cat("  total_orders:", round(t6_results$coef[2], 4), "\n")
cat("  total_fee:", round(t6_results$coef[3], 4), "\n")
cat("  total_labor:", round(t6_results$coef[4], 4), "\n")

################################################################################
# Table 7: AI impact on customer waiting time
################################################################################
cat("\n--- Table 7: 고객 대기시간 ---\n")

orders_m <- fread("data/processed/orders_matched.csv")
orders_m[, station_date := paste(management_partner_id, ymd, sep = "_")]
orders_m[, hour := hour(as.POSIXct(assigned_at))]
orders_m[, DOW := wday(as.Date(ymd))]
orders_m[, hourDOW := paste(hour, DOW, sep = "_")]

# waiting_min 변수 생성
orders_m[, waiting_min := waiting_sec / 60]
orders_m[, after_treat := after * Treat]

# shift 내 주문 수로 단건/합배송 구분 (total_order 컬럼은 전부 1이라 사용 불가)
shift_size <- orders_m[, .(shift_n_orders = .N), by = .(rider_id, ymd, shift)]
orders_m <- merge(orders_m, shift_size, by = c("rider_id", "ymd", "shift"), all.x = TRUE)
orders_m[, is_single := as.integer(shift_n_orders == 1)]

cat("  단건:", sum(orders_m$is_single == 1), "/ 합배:", sum(orders_m$is_single == 0), "\n")

# 전체 주문 대기시간
did_wait <- felm(waiting_min ~ after_treat + distorigintodest | rider_id + station_date + hourDOW | 0 | rider_id,
                 data = orders_m)

# 단건 배송
did_wait_single <- felm(waiting_min ~ after_treat + distorigintodest | rider_id + station_date + hourDOW | 0 | rider_id,
                        data = orders_m[is_single == 1])

# 합배송
did_wait_stack <- felm(waiting_min ~ after_treat + distorigintodest | rider_id + station_date + hourDOW | 0 | rider_id,
                       data = orders_m[is_single == 0])

t7_results <- data.frame(
  type = c("all", "single", "stacked"),
  coef = c(coef(did_wait)["after_treat"], coef(did_wait_single)["after_treat"],
           coef(did_wait_stack)["after_treat"]),
  se = c(summary(did_wait)$coef["after_treat", "Cluster s.e."],
         summary(did_wait_single)$coef["after_treat", "Cluster s.e."],
         summary(did_wait_stack)$coef["after_treat", "Cluster s.e."]),
  pval = c(summary(did_wait)$coef["after_treat", "Pr(>|t|)"],
           summary(did_wait_single)$coef["after_treat", "Pr(>|t|)"],
           summary(did_wait_stack)$coef["after_treat", "Pr(>|t|)"])
)
fwrite(t7_results, "output/tables/table7_waiting_time.csv")
cat("  전체:", round(t7_results$coef[1], 3), "분 (p=", round(t7_results$pval[1], 4), ")\n")
cat("  단건:", round(t7_results$coef[2], 3), "분 (p=", round(t7_results$pval[2], 4), ")\n")
cat("  합배:", round(t7_results$coef[3], 3), "분 (p=", round(t7_results$pval[3], 4), ")\n")

################################################################################
# 종합 비교
################################################################################
cat("\n=== 재현 검증 종합 ===\n")
cat("논문 주요 발견 vs 재현:\n")
cat("1. 일일 생산성 DID: 논문 ≈ +3% → 재현:", round(t4_results$coef[1], 4), "\n")
cat("2. Medium DDD: 논문 ≈ +5% → 재현:", round(t4_results$coef[3], 4), "\n")
cat("3. 대기시간(전체): 논문 = 비유의 → 재현 p=", round(t7_results$pval[1], 4), "\n")
cat("4. 대기시간(단건): 논문 = 유의 감소 → 재현 p=", round(t7_results$pval[2], 4), "\n")
cat("\n모든 결과가 output/tables/에 저장됨\n")
