################################################################################
# 00_data_preparation_v2.R
# 두 데이터 파일 합친 전처리 파이프라인
# riders_full.csv (9.2M) + new_data.csv (8.6M) → 중복 제거 → 분석
################################################################################
library(data.table)
library(dplyr)
library(lubridate)

cat("=== Phase 0 v2: 두 데이터 통합 전처리 ===\n")
cat("시작:", format(Sys.time()), "\n\n")

setwd("/Users/gujaeseo/Documents/projects/yeonseo/ijim_ai_research")
dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)

################################################################################
# 1. 두 데이터 로드 & 컬럼 정규화
################################################################################
cat("[1/8] 데이터 로드 & 컬럼 정규화...\n")

# riders_full.csv (원본 1)
d1 <- fread("data/riders_full.csv")
cat("  riders_full.csv:", nrow(d1), "행\n")
# 컬럼명 정규화
setnames(d1, c("submittedat","assignedat","pickedupat","deliveredat"),
         c("submitted_at","assigned_at","picked_up_at","delivered_at"), skip_absent=TRUE)
setnames(d1, "agent_id", "rider_id", skip_absent=TRUE)
setnames(d1, "agent_fee", "rider_fee", skip_absent=TRUE)
setnames(d1, "agent_extra_fee", "rider_extra_fee", skip_absent=TRUE)
setnames(d1, "distorigintodest", "distance", skip_absent=TRUE)
setnames(d1, "dest_lat_masked", "dest_lat", skip_absent=TRUE)
setnames(d1, "dest_lng_masked", "dest_lng", skip_absent=TRUE)

# new_data.csv (원본 2)
d2 <- fread("data/new_data.csv")
cat("  new_data.csv:", nrow(d2), "행\n")
setnames(d2, "agent_id", "rider_id", skip_absent=TRUE)
setnames(d2, "agent_fee", "rider_fee", skip_absent=TRUE)
setnames(d2, "agent_extra_fee", "rider_extra_fee", skip_absent=TRUE)
setnames(d2, "monitoring_partner_id", "monitoringpartner_id", skip_absent=TRUE)

# 공통 컬럼만 추출하여 합치기
common_cols <- intersect(names(d1), names(d2))
cat("  공통 컬럼:", length(common_cols), "개:", paste(common_cols, collapse=", "), "\n")

d_all <- rbind(d1[, ..common_cols], d2[, ..common_cols])
rm(d1, d2); gc()

cat("  합친 후:", nrow(d_all), "행\n")

# 중복 order_id 제거 (원본 코드와 동일)
d_all <- d_all[!duplicated(order_id)]
cat("  중복 제거 후:", nrow(d_all), "행\n")

################################################################################
# 2. 기본 전처리
################################################################################
cat("[2/8] 기본 전처리...\n")

# 타임스탬프
d_all[, submitted_at := as.POSIXct(submitted_at, tz="UTC")]
d_all[, assigned_at := as.POSIXct(assigned_at, tz="UTC")]
d_all[, picked_up_at := as.POSIXct(picked_up_at, tz="UTC")]
d_all[, delivered_at := as.POSIXct(delivered_at, tz="UTC")]

# NA 제거
d_all <- d_all[!is.na(picked_up_at) & !is.na(delivered_at)]
cat("  NA 제거 후:", nrow(d_all), "행\n")

################################################################################
# 3. 부산 필터링
################################################################################
cat("[3/8] 부산 필터링...\n")

# partner_name 있으면 사용, 없으면 management_partner_id 기반
# riders_full에는 partner_name 있고 전부 부산
# new_data에는 partner_name 없음 → management_partner_id로 필터

# rider_info에서 부산 지점 ID 추출
rider_info <- fread("data/rider_info.csv")
busan_partners <- unique(rider_info[grepl("부산", management_partner_name), management_partner_id])
cat("  부산 지점 ID:", length(busan_partners), "개\n")

# 부산 지점 필터
d_busan <- d_all[management_partner_id %in% busan_partners]
# 울산/진해 제외 (rider_info에서 확인)
exclude_partners <- rider_info[grepl("울산|진해", management_partner_name), management_partner_id]
d_busan <- d_busan[!management_partner_id %in% exclude_partners]

cat("  부산 주문:", nrow(d_busan), "행,", uniqueN(d_busan$rider_id), "라이더\n")
cat("  기간:", as.character(min(d_busan$submitted_at)), "~", as.character(max(d_busan$submitted_at)), "\n")
cat("  AI 배정:", sum(d_busan$is_rec_assigned, na.rm=TRUE), "건\n")
rm(d_all); gc()

# rider_info merge (입직 시기)
rider_dates <- rider_info[, .(created_at = min(as.POSIXct(created_at, format="%Y-%m-%d %H:%M"))), by=rider_id]
d_busan <- merge(d_busan, rider_dates, by="rider_id", all.x=TRUE)

################################################################################
# 4. 분석 기간 & 변수 생성
################################################################################
cat("[4/8] 분석 기간 & 변수 생성...\n")

d_busan[, ymd := as.Date(submitted_at)]
AI_DATE <- as.Date("2020-10-26")
PRE_START <- as.Date("2020-09-26")
POST_END <- as.Date("2020-11-25")

orders_analysis <- d_busan[ymd >= PRE_START & ymd <= POST_END]
cat("  분석 기간 주문:", nrow(orders_analysis), "행,", uniqueN(orders_analysis$rider_id), "라이더\n")

orders_analysis[, after := ifelse(ymd >= AI_DATE, 1L, 0L)]
orders_analysis[, assign_sec := as.numeric(difftime(assigned_at, submitted_at, units="secs"))]
orders_analysis[, pickup_sec := as.numeric(difftime(picked_up_at, assigned_at, units="secs"))]
orders_analysis[, delivery_sec := as.numeric(difftime(delivered_at, picked_up_at, units="secs"))]
orders_analysis[, waiting_sec := as.numeric(difftime(delivered_at, submitted_at, units="secs"))]
orders_analysis[, rider_total_fee := rider_fee + rider_extra_fee]
orders_analysis <- orders_analysis[rider_total_fee > 0]
orders_analysis[, hour := hour(assigned_at)]
orders_analysis[, DOW := wday(ymd)]
orders_analysis[, hourDOW := paste(hour, DOW, sep="_")]
orders_analysis[, station_date := paste(management_partner_id, ymd, sep="_")]

cat("  최종 분석 주문:", nrow(orders_analysis), "행,", uniqueN(orders_analysis$rider_id), "라이더\n")

################################################################################
# 5. Shift(스택) 정의
################################################################################
cat("[5/8] Shift 정의...\n")

setorder(orders_analysis, rider_id, ymd, assigned_at)
orders_analysis[, delivered_at_num := as.numeric(delivered_at)]
orders_analysis[, delivered_at_cummax := cummax(delivered_at_num), by=.(ymd, rider_id)]
orders_analysis[, delivered_at_max := as.POSIXct(delivered_at_cummax, origin="1970-01-01", tz="UTC")]

func_check <- function(assigned, del_max) {
  n <- length(assigned)
  if (n == 1) return(1L)
  c(1L, ifelse(assigned[-1] <= del_max[-n], 1L, 0L))
}

orders_analysis[, check := func_check(assigned_at, delivered_at_max), by=.(ymd, rider_id)]
orders_analysis[, shift := cumsum(check == 0L) + 1L, by=.(ymd, rider_id)]

cat("  총 shift:", orders_analysis[, uniqueN(paste(rider_id, ymd, shift))], "\n")

################################################################################
# 6. Treatment & Proficiency
################################################################################
cat("[6/8] Treatment & Proficiency...\n")

treat_riders <- unique(orders_analysis[is_rec_assigned == 1, rider_id])
orders_analysis[, Treat := ifelse(rider_id %in% treat_riders, 1L, 0L)]
cat("  Treat:", length(treat_riders), "명, Control:", uniqueN(orders_analysis$rider_id) - length(treat_riders), "명\n")

# Shift-level
data_shift <- orders_analysis[, .(
  num_orders = .N,
  shift_profit = sum(rider_total_fee),
  start = assigned_at[1],
  finish = max(delivered_at),
  total_duration = as.numeric(difftime(max(delivered_at), assigned_at[1], units="mins")),
  avg_assign = mean(assign_sec, na.rm=TRUE),
  avg_pickup = mean(pickup_sec, na.rm=TRUE),
  avg_deliver = mean(delivery_sec, na.rm=TRUE),
  avg_waiting = mean(waiting_sec, na.rm=TRUE),
  is_rec_any = max(is_rec_assigned, na.rm=TRUE)
), by=.(rider_id, Treat, management_partner_id, ymd, after, shift)]

data_shift[, avg_duration_orders := total_duration / num_orders]
data_shift <- data_shift[order(rider_id, ymd, shift)]
data_shift[, idle_btw_shifts := c(NA, as.numeric(difftime(start[-1], finish[-.N], units="secs"))), by=.(rider_id, ymd)]
data_shift[idle_btw_shifts > 3600, idle_btw_shifts := NA]
data_shift[, idle_btw_shifts := idle_btw_shifts / 60]
data_shift[, start_hour := hour(start)]
data_shift[, wday := wday(as.Date(ymd))]
data_shift[, hourDOW := paste(start_hour, wday, sep="_")]

# Day-level
data_day <- data_shift[, .(
  total_shift = .N,
  total_orders = sum(num_orders),
  total_fee = sum(shift_profit),
  working_duration = sum(total_duration) / 60,
  idle_duration = sum(idle_btw_shifts, na.rm=TRUE) / 60,
  orders_one = sum(num_orders == 1)
), by=.(rider_id, Treat, management_partner_id, ymd, after)]
data_day[, total_labor := working_duration + idle_duration]
data_day[, orders_per_hour := total_orders / total_labor]
data_day[, share_idled := idle_duration / total_labor]

# Proficiency
proficiency <- data_day[after == 0, .(prof = mean(orders_per_hour, na.rm=TRUE)), by=rider_id]
prof_cutoffs <- quantile(proficiency$prof, probs=c(1/3, 2/3), na.rm=TRUE)
cat("  Proficiency 경계:", round(prof_cutoffs, 3), "\n")
proficiency[, prof_group := ifelse(prof < prof_cutoffs[1], "low", ifelse(prof < prof_cutoffs[2], "med", "high"))]
proficiency[, `:=`(prof_low = as.integer(prof_group=="low"), prof_med = as.integer(prof_group=="med"), prof_high = as.integer(prof_group=="high"))]
cat("  Low:", sum(proficiency$prof_low), "/ Med:", sum(proficiency$prof_med), "/ High:", sum(proficiency$prof_high), "\n")

# Merge proficiency
data_shift <- merge(data_shift, proficiency[, .(rider_id, prof, prof_group, prof_low, prof_med, prof_high)], by="rider_id", all.x=TRUE)
data_day <- merge(data_day, proficiency[, .(rider_id, prof, prof_group, prof_low, prof_med, prof_high)], by="rider_id", all.x=TRUE)
orders_analysis <- merge(orders_analysis, proficiency[, .(rider_id, prof, prof_group, prof_low, prof_med, prof_high)], by="rider_id", all.x=TRUE)

data_shift_f <- data_shift[!is.na(prof)]
data_day_f <- data_day[!is.na(prof)]
orders_f <- orders_analysis[!is.na(prof)]

cat("  최종 shift:", nrow(data_shift_f), "/ day:", nrow(data_day_f), "/ order:", nrow(orders_f), "\n")

################################################################################
# 7. PSM 매칭
################################################################################
cat("[7/8] PSM 매칭...\n")
library(MatchIt)

pre_day <- data_day_f[after == 0]
pre_var <- pre_day[, .(
  daily_total_order = mean(total_orders), daily_working_duration = mean(working_duration),
  daily_idle_duration = mean(idle_duration), daily_total_labor = mean(total_labor),
  daily_orders_per_hour = mean(orders_per_hour), daily_total_shift = mean(total_shift),
  daily_profit = mean(total_fee)
), by=.(rider_id, Treat)]

pre_shift <- data_shift_f[after == 0]
pre_shift_var <- pre_shift[, .(
  avg_orders_shift = mean(num_orders), avg_duration_shift = mean(total_duration),
  avg_idle_shift = mean(idle_btw_shifts, na.rm=TRUE), avg_waiting_shift = mean(avg_waiting)
), by=rider_id]

pre_order_var <- orders_f[after == 0, .(
  daily_delivered_stores = length(unique(store_id)) / length(unique(ymd))
), by=rider_id]

pre_week <- orders_f[after == 0]
pre_week[, week := week(as.Date(ymd))]
num_wd <- pre_week[, .(days = uniqueN(ymd)), by=.(rider_id, week)]
num_wd <- num_wd[, .(num_working_days = mean(days)), by=rider_id]

pre_var <- Reduce(function(a, b) merge(a, b, by="rider_id", all.x=TRUE),
                  list(pre_var, pre_shift_var, pre_order_var, num_wd))
pre_var_nona <- na.omit(pre_var)
cat("  매칭 대상:", nrow(pre_var_nona), "명 (Treat=1:", sum(pre_var_nona$Treat), ")\n")

tryCatch({
  psm <- matchit(Treat ~ daily_delivered_stores + num_working_days +
                    avg_waiting_shift + avg_orders_shift + avg_duration_shift + avg_idle_shift +
                    daily_total_labor + daily_idle_duration,
                  method="nearest", data=as.data.frame(pre_var_nona),
                  caliper=0.05, std.caliper=TRUE, discard="both")
  matched_data <- match.data(psm)
  matched_riders <- matched_data$rider_id
  cat("  매칭 완료:", length(matched_riders), "명 (", sum(matched_data$Treat), "쌍)\n")
  data_shift_matched <- data_shift_f[rider_id %in% matched_riders]
  data_day_matched <- data_day_f[rider_id %in% matched_riders]
  orders_matched <- orders_f[rider_id %in% matched_riders]
}, error = function(e) {
  cat("  PSM 에러:", conditionMessage(e), "\n매칭 없이 진행\n")
  matched_riders <<- unique(pre_var_nona$rider_id)
  data_shift_matched <<- data_shift_f
  data_day_matched <<- data_day_f
  orders_matched <<- orders_f
})

################################################################################
# 8. 저장
################################################################################
cat("[8/8] 저장...\n")
fwrite(data_shift_f, "data/processed/data_shift_full.csv")
fwrite(data_day_f, "data/processed/data_day_full.csv")
fwrite(data_shift_matched, "data/processed/data_shift_matched.csv")
fwrite(data_day_matched, "data/processed/data_day_matched.csv")
fwrite(orders_matched, "data/processed/orders_matched.csv")
fwrite(as.data.frame(pre_var_nona), "data/processed/pre_matching_vars.csv")
if (exists("matched_data")) fwrite(matched_data, "data/processed/matched_riders.csv")
fwrite(proficiency, "data/processed/proficiency.csv")

# Event-study용 확장 데이터
orders_ext <- d_busan[ymd >= as.Date("2020-04-01") & ymd <= POST_END]
orders_ext[, after := ifelse(ymd >= AI_DATE, 1L, 0L)]
orders_ext[, Treat := ifelse(rider_id %in% treat_riders, 1L, 0L)]
fwrite(orders_ext, "data/processed/orders_busan_extended.csv")

cat("\n=== v2 전처리 완료 ===\n")
cat("완료:", format(Sys.time()), "\n")
cat("분석 기간:", as.character(PRE_START), "~", as.character(POST_END), "\n")
cat("매칭 전:", uniqueN(data_day_f$rider_id), "/ 매칭 후:", length(matched_riders), "\n")
cat("Treat:", length(treat_riders), "/ Proficiency:", round(prof_cutoffs, 3), "\n")
