################################################################################
# 00_data_preparation.R
# IJIM 논문 수정: 데이터 전처리 파이프라인
# 원본 코드(data preparation_231001.r) 기반 재현 + 신규 분석용 데이터 생성
#
# 입력: data/riders_full.csv, data/rider_info.csv
# 출력: data/processed/ 폴더에 분석용 데이터셋
################################################################################

library(data.table)
library(dplyr)
library(lubridate)

cat("=== Phase 0: 데이터 전처리 시작 ===\n")
cat("시작 시각:", format(Sys.time()), "\n\n")

setwd("/Users/gujaeseo/Documents/projects/yeonseo/ijim_ai_research")
dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)

################################################################################
# 1. 원본 데이터 로드
################################################################################
cat("[1/8] 원본 데이터 로드 중...\n")

# riders_full.csv: 주문 데이터 (918만 행)
orders_raw <- fread("data/riders_full.csv", stringsAsFactors = FALSE)
cat("  전체 주문:", nrow(orders_raw), "행,", length(unique(orders_raw$agent_id)), "라이더\n")

# rider_info.csv: 라이더 정보 (입직 시기)
rider_info <- fread("data/rider_info.csv", stringsAsFactors = FALSE)
rider_info <- rider_info[, .(rider_id, created_at, management_partner_id, management_partner_name)]
rider_info$created_at <- as.POSIXct(rider_info$created_at, format = "%Y-%m-%d %H:%M")
# 중복 라이더: 가장 이른 입직 시기 사용
rider_info <- rider_info[, .(created_at = min(created_at, na.rm = TRUE)), by = rider_id]

################################################################################
# 2. 컬럼명 정리 & 기본 전처리
################################################################################
cat("[2/8] 컬럼 정리 및 기본 전처리...\n")

# agent_id -> rider_id (원본 코드와 일치)
setnames(orders_raw, "agent_id", "rider_id")
setnames(orders_raw, "agent_fee", "rider_fee")
setnames(orders_raw, "agent_extra_fee", "rider_extra_fee")

# 타임스탬프 변환
orders_raw[, submitted_at := as.POSIXct(submittedat, tz = "UTC")]
orders_raw[, assigned_at := as.POSIXct(assignedat, tz = "UTC")]
orders_raw[, picked_up_at := as.POSIXct(pickedupat, tz = "UTC")]
orders_raw[, delivered_at := as.POSIXct(deliveredat, tz = "UTC")]

# NA 제거 (원본 코드와 동일)
orders_raw <- orders_raw[!is.na(picked_up_at) & !is.na(delivered_at)]

# 중복 주문 제거 (원본: group_by(order_id) %>% filter(row_number()==1))
orders_raw <- orders_raw[!duplicated(order_id)]

cat("  전처리 후:", nrow(orders_raw), "행\n")

################################################################################
# 3. 부산 지역 필터링
################################################################################
cat("[3/8] 부산 지역 필터링...\n")

# partner_name에 "부산" 포함하는 주문 (원본: si_do=="부산광역시")
# riders_full.csv에는 si_do 컬럼이 없으므로 partner_name으로 필터
orders_busan <- orders_raw[grepl("부산", partner_name)]

# 울산/진해 등 부산 외 지점 제거 (원본 코드 참조)
orders_busan <- orders_busan[!grepl("울산|진해", partner_name)]

cat("  부산 주문:", nrow(orders_busan), "행,",
    length(unique(orders_busan$rider_id)), "라이더\n")
cat("  기간:", as.character(min(orders_busan$submitted_at)), "~",
    as.character(max(orders_busan$submitted_at)), "\n")
cat("  AI 배정(is_rec_assigned=1):", sum(orders_busan$is_rec_assigned, na.rm = TRUE), "건\n")

# rider_info merge (입직 시기)
orders_busan <- merge(orders_busan, rider_info, by = "rider_id", all.x = TRUE)

################################################################################
# 4. 분석 기간 필터링 & 변수 생성
################################################################################
cat("[4/8] 분석 기간 필터 및 변수 생성...\n")

# 날짜 변수
orders_busan[, ymd := as.Date(submitted_at)]

# AI 도입일: 2020-10-26
AI_DATE <- as.Date("2020-10-26")

# 분석 기간: 도입 전 1개월 + 도입 후 1개월 (논문과 동일)
# 도입 전: 2020-09-26 ~ 2020-10-25
# 도입 후: 2020-10-26 ~ 2020-11-25
PRE_START <- as.Date("2020-09-26")
POST_END <- as.Date("2020-11-25")

orders_analysis <- orders_busan[ymd >= PRE_START & ymd <= POST_END]
cat("  분석 기간 주문:", nrow(orders_analysis), "행\n")

# after 더미 (도입 후 = 1)
orders_analysis[, after := ifelse(ymd >= AI_DATE, 1L, 0L)]

# 소요시간 변수 (초 단위)
orders_analysis[, assign_sec := as.numeric(difftime(assigned_at, submitted_at, units = "secs"))]
orders_analysis[, pickup_sec := as.numeric(difftime(picked_up_at, assigned_at, units = "secs"))]
orders_analysis[, delivery_sec := as.numeric(difftime(delivered_at, picked_up_at, units = "secs"))]
orders_analysis[, waiting_sec := as.numeric(difftime(delivered_at, submitted_at, units = "secs"))]

# 라이더 총 수수료
orders_analysis[, rider_total_fee := rider_fee + rider_extra_fee]

# 수수료 0인 주문 제거
orders_analysis <- orders_analysis[rider_total_fee > 0]

# 시간 변수
orders_analysis[, hour := hour(assigned_at)]
orders_analysis[, DOW := wday(ymd)]
orders_analysis[, hourDOW := paste(hour, DOW, sep = "_")]
orders_analysis[, station_date := paste(management_partner_id, ymd, sep = "_")]

cat("  최종 분석 주문:", nrow(orders_analysis), "행,",
    length(unique(orders_analysis$rider_id)), "라이더\n")

################################################################################
# 5. Shift(스택) 정의
################################################################################
cat("[5/8] Shift(스택) 번호 생성...\n")

# 원본 로직: 라이더별 일별, 배차시각 순 정렬
# delivered_at의 누적 최대값(cummax)과 다음 주문의 assigned_at 비교
# assigned_at > cummax(delivered_at) 이면 새 shift 시작

setorder(orders_analysis, rider_id, ymd, assigned_at)

orders_analysis[, delivered_at_num := as.numeric(delivered_at)]
orders_analysis[, delivered_at_cummax := cummax(delivered_at_num), by = .(ymd, rider_id)]
orders_analysis[, delivered_at_max := as.POSIXct(delivered_at_cummax, origin = "1970-01-01", tz = "UTC")]

# shift 번호: assigned_at이 이전 주문들의 최대 delivered_at보다 늦으면 새 shift
func_check <- function(assigned, del_max) {
  n <- length(assigned)
  if (n == 1) return(1L)
  check <- c(1L, ifelse(assigned[-1] <= del_max[-n], 1L, 0L))
  return(check)
}

orders_analysis[, check := func_check(assigned_at, delivered_at_max), by = .(ymd, rider_id)]
orders_analysis[, shift := cumsum(check == 0L) + 1L, by = .(ymd, rider_id)]

cat("  총 shift 수:", orders_analysis[, uniqueN(paste(rider_id, ymd, shift))], "\n")

################################################################################
# 6. Treatment 정의 & Proficiency 분류
################################################################################
cat("[6/8] Treatment 및 Proficiency 정의...\n")

# Treatment: is_rec_assigned==1인 주문을 1회라도 수행한 라이더
treat_riders <- unique(orders_analysis[is_rec_assigned == 1, rider_id])
orders_analysis[, Treat := ifelse(rider_id %in% treat_riders, 1L, 0L)]

cat("  AI 채택자 (Treat=1):", length(treat_riders), "명\n")
cat("  비채택자 (Treat=0):", orders_analysis[, uniqueN(rider_id)] - length(treat_riders), "명\n")

# Shift-level 집계
data_shift <- orders_analysis[, .(
  num_orders = .N,
  shift_profit = sum(rider_total_fee),
  start = assigned_at[1],
  finish = max(delivered_at),
  total_duration = as.numeric(difftime(max(delivered_at), assigned_at[1], units = "mins")),
  avg_assign = mean(assign_sec, na.rm = TRUE),
  avg_pickup = mean(pickup_sec, na.rm = TRUE),
  avg_deliver = mean(delivery_sec, na.rm = TRUE),
  avg_waiting = mean(waiting_sec, na.rm = TRUE),
  is_rec_any = max(is_rec_assigned, na.rm = TRUE)
), by = .(rider_id, Treat, management_partner_id, ymd, after, shift)]

# 주문당 평균 소요시간
data_shift[, avg_duration_orders := total_duration / num_orders]

# Idle time (shift 간)
data_shift <- data_shift[order(rider_id, ymd, shift)]
data_shift[, idle_btw_shifts := c(NA, as.numeric(difftime(start[-1], finish[-.N], units = "secs"))),
           by = .(rider_id, ymd)]
# 1시간 이상 idle은 NA 처리 (원본과 동일)
data_shift[idle_btw_shifts > 3600, idle_btw_shifts := NA]
# 분 단위 변환
data_shift[, idle_btw_shifts := idle_btw_shifts / 60]

# hourDOW
data_shift[, start_hour := hour(start)]
data_shift[, wday := wday(ymd)]
data_shift[, hourDOW := paste(start_hour, wday, sep = "_")]

# Day-level 집계
data_day <- data_shift[, .(
  total_shift = .N,
  total_orders = sum(num_orders),
  total_fee = sum(shift_profit),
  working_duration = sum(total_duration) / 60,  # 시간 단위
  idle_duration = sum(idle_btw_shifts, na.rm = TRUE) / 60,  # 시간 단위
  orders_one = sum(num_orders == 1)  # 단건 배송 수
), by = .(rider_id, Treat, management_partner_id, ymd, after)]

data_day[, total_labor := working_duration + idle_duration]
data_day[, orders_per_hour := total_orders / total_labor]
data_day[, share_idled := idle_duration / total_labor]

# Proficiency: 도입 전 평균 orders_per_hour로 3분위
proficiency <- data_day[after == 0, .(prof = mean(orders_per_hour, na.rm = TRUE)), by = rider_id]

prof_cutoffs <- quantile(proficiency$prof, probs = c(1/3, 2/3), na.rm = TRUE)
cat("  Proficiency 경계값:", round(prof_cutoffs, 3), "\n")

proficiency[, prof_group := ifelse(prof < prof_cutoffs[1], "low",
                            ifelse(prof < prof_cutoffs[2], "med", "high"))]
proficiency[, `:=`(
  prof_low = as.integer(prof_group == "low"),
  prof_med = as.integer(prof_group == "med"),
  prof_high = as.integer(prof_group == "high")
)]

cat("  Low:", sum(proficiency$prof_low), "/ Med:", sum(proficiency$prof_med),
    "/ High:", sum(proficiency$prof_high), "명\n")

# Proficiency merge
data_shift <- merge(data_shift, proficiency[, .(rider_id, prof, prof_group, prof_low, prof_med, prof_high)],
                    by = "rider_id", all.x = TRUE)
data_day <- merge(data_day, proficiency[, .(rider_id, prof, prof_group, prof_low, prof_med, prof_high)],
                  by = "rider_id", all.x = TRUE)
orders_analysis <- merge(orders_analysis, proficiency[, .(rider_id, prof, prof_group, prof_low, prof_med, prof_high)],
                         by = "rider_id", all.x = TRUE)

# proficiency NA 제거 (도입 전 기록 없는 라이더)
data_shift_f <- data_shift[!is.na(prof)]
data_day_f <- data_day[!is.na(prof)]
orders_f <- orders_analysis[!is.na(prof)]

cat("  최종 shift 데이터:", nrow(data_shift_f), "행\n")
cat("  최종 day 데이터:", nrow(data_day_f), "행\n")
cat("  최종 order 데이터:", nrow(orders_f), "행\n")

################################################################################
# 7. PSM 매칭
################################################################################
cat("[7/8] PSM 매칭...\n")

library(MatchIt)

# 매칭 공변량 생성 (도입 전 데이터)
pre_shift <- data_shift_f[after == 0]
pre_day <- data_day_f[after == 0]

pre_var <- pre_day[, .(
  daily_total_order = mean(total_orders),
  daily_working_duration = mean(working_duration),
  daily_idle_duration = mean(idle_duration),
  daily_total_labor = mean(total_labor),
  daily_orders_per_hour = mean(orders_per_hour),
  daily_share_idled = mean(share_idled, na.rm = TRUE),
  daily_total_shift = mean(total_shift),
  daily_profit = mean(total_fee)
), by = .(rider_id, Treat)]

pre_shift_var <- pre_shift[, .(
  avg_orders_shift = mean(num_orders),
  avg_duration_shift = mean(total_duration),
  avg_idle_shift = mean(idle_btw_shifts, na.rm = TRUE),
  avg_waiting_shift = mean(avg_waiting),
  avg_duration_orders = mean(avg_duration_orders, na.rm = TRUE)
), by = rider_id]

pre_order_var <- orders_f[after == 0, .(
  avg_assign = mean(assign_sec, na.rm = TRUE),
  avg_pickup = mean(pickup_sec, na.rm = TRUE),
  avg_deliver = mean(delivery_sec, na.rm = TRUE),
  avg_waiting = mean(waiting_sec, na.rm = TRUE),
  avg_ODdist = mean(distorigintodest, na.rm = TRUE),
  daily_delivered_stores = length(unique(store_id)) / length(unique(ymd))
), by = rider_id]

# 주간 근무일수
pre_week <- orders_f[after == 0]
pre_week[, week := week(ymd)]
num_working_days <- pre_week[, .(days = uniqueN(ymd)), by = .(rider_id, week)]
num_working_days <- num_working_days[, .(num_working_days = mean(days)), by = rider_id]

# 재직 기간
tenure_data <- orders_f[, .(created_at = min(created_at, na.rm = TRUE)), by = rider_id]
tenure_data[, tenure := as.numeric(difftime(AI_DATE, created_at, units = "days"))]

pre_var <- merge(pre_var, pre_shift_var, by = "rider_id", all.x = TRUE)
pre_var <- merge(pre_var, pre_order_var, by = "rider_id", all.x = TRUE)
pre_var <- merge(pre_var, num_working_days, by = "rider_id", all.x = TRUE)
pre_var <- merge(pre_var, tenure_data[, .(rider_id, tenure)], by = "rider_id", all.x = TRUE)
pre_var <- merge(pre_var, proficiency[, .(rider_id, prof, prof_low, prof_med, prof_high)],
                 by = "rider_id", all.x = TRUE)

pre_var_nona <- na.omit(pre_var)
cat("  매칭 대상 라이더:", nrow(pre_var_nona), "명 (Treat=1:", sum(pre_var_nona$Treat), "명)\n")

# PSM 1:1 nearest matching, caliper 0.05 (원본과 동일)
tryCatch({
  psm <- matchit(Treat ~ daily_delivered_stores + num_working_days +
                    avg_waiting_shift + avg_orders_shift + avg_duration_shift + avg_idle_shift +
                    daily_total_labor + daily_idle_duration,
                  method = "nearest", data = as.data.frame(pre_var_nona),
                  caliper = 0.05, std.caliper = TRUE, discard = "both")

  matched_data <- match.data(psm)
  matched_riders <- matched_data$rider_id

  cat("  매칭 완료:", length(matched_riders), "명 (",
      sum(matched_data$Treat), "쌍)\n")

  # 매칭된 라이더만 필터
  data_shift_matched <- data_shift_f[rider_id %in% matched_riders]
  data_day_matched <- data_day_f[rider_id %in% matched_riders]
  orders_matched <- orders_f[rider_id %in% matched_riders]

}, error = function(e) {
  cat("  PSM 매칭 에러:", conditionMessage(e), "\n")
  cat("  매칭 없이 전체 데이터로 진행\n")
  matched_riders <<- unique(pre_var_nona$rider_id)
  data_shift_matched <<- data_shift_f
  data_day_matched <<- data_day_f
  orders_matched <<- orders_f
})

################################################################################
# 8. 데이터 저장
################################################################################
cat("[8/8] 데이터 저장...\n")

# 전체 데이터 (매칭 전)
fwrite(data_shift_f, "data/processed/data_shift_full.csv")
fwrite(data_day_f, "data/processed/data_day_full.csv")

# 매칭 데이터
fwrite(data_shift_matched, "data/processed/data_shift_matched.csv")
fwrite(data_day_matched, "data/processed/data_day_matched.csv")
fwrite(orders_matched, "data/processed/orders_matched.csv")

# 매칭 정보
fwrite(as.data.frame(pre_var_nona), "data/processed/pre_matching_vars.csv")
if (exists("matched_data")) fwrite(matched_data, "data/processed/matched_riders.csv")
fwrite(proficiency, "data/processed/proficiency.csv")

# 부산 전체 주문 데이터 (event-study용: 긴 기간)
cat("  Event-study용 확장 데이터 저장 중...\n")
orders_busan_extended <- orders_busan[ymd >= as.Date("2020-04-01") & ymd <= POST_END]
orders_busan_extended[, after := ifelse(ymd >= AI_DATE, 1L, 0L)]
orders_busan_extended[, Treat := ifelse(rider_id %in% treat_riders, 1L, 0L)]
fwrite(orders_busan_extended, "data/processed/orders_busan_extended.csv")

cat("\n=== 전처리 완료 ===\n")
cat("완료 시각:", format(Sys.time()), "\n")
cat("\n저장된 파일:\n")
list.files("data/processed", full.names = TRUE) |> cat(sep = "\n")

cat("\n\n=== 요약 통계 ===\n")
cat("분석 기간:", as.character(PRE_START), "~", as.character(POST_END), "\n")
cat("AI 도입일:", as.character(AI_DATE), "\n")
cat("매칭 전 라이더:", data_day_f[, uniqueN(rider_id)], "\n")
cat("매칭 후 라이더:", length(matched_riders), "\n")
cat("Treat (AI 채택):", length(treat_riders), "\n")
cat("Proficiency 경계:", round(prof_cutoffs, 3), "\n")
cat("  Low:", sum(proficiency$prof_low), "/ Med:", sum(proficiency$prof_med),
    "/ High:", sum(proficiency$prof_high), "\n")
