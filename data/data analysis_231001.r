#####################################################################################################################
##### Pretreatment period data를 활용한 matching covariates 만들기
#####################################################################################################################

### pretreatment 데이터 추출
data_order_pre <- data_order.f %>% filter(after==0)
length(unique(data_order_pre$date)) # pretreatment period: 30 days (2020-09-26 ~ 2020-10-25)

##### 평균 배차/픽업/배달 소요시간
pre_var <- data_order_pre %>% 
  group_by(rider_id) %>% 
  summarise(avg_assign = mean(assign_min), avg_pickup = mean(pickup_min), avg_deliver = mean(delivery_min), avg_waiting = mean(waiting_min))
#hist(pre_var$avg_assign, breaks=532, main = "Avg. assign duration", xlab="avg_assign")
#hist(pre_var$avg_pickup, breaks=532, main = "Avg. pickup duration", xlab="avg_pickup")
#hist(pre_var$avg_deliver, breaks=532, main = "Avg. deliver duration", xlab="avg_deliver")
#hist(pre_var$avg_waiting, breaks=532, main = "Avg. assign to deliver duration", xlab="avg_assign_to_deliver")

##### 평균 배달 직선거리
test <- data_order_pre %>%
  group_by(rider_id) %>%
  summarise(avg_ODdist = mean(distorigintodest, na.rm=T))
pre_var <- left_join(pre_var, test)
#hist(pre_var$avg_ODdist, breaks=533, main = "Avg. OD distance", xlab="avg_OD_distance", xlim=c(0.5,3))

##### 하루 평균 배달 상점수
test <- data_order_pre %>% 
  group_by(rider_id, date) %>%
  summarise(num_delivered_stores = length(unique(store_id))) %>%
  group_by(rider_id) %>%
  summarise(daily_delivered_stores = mean(num_delivered_stores))
#hist(test$daily_delivered_stores, breaks=533, main = "Number of daily delivered stores", xlab="Number of stores")

pre_var <- left_join(pre_var, test)

##### 주간 노동 일수
# 주, 요일 정의
unique(data_order_pre$date) #2020-09-26 ~ 2020-10-25
data_order_pre$date <- as.character(data_order_pre$date)
data_order_pre <- data_order_pre %>% mutate(week = ifelse(date %in% c("2020-09-26"),1,
                                                          ifelse(date %in% c("2020-09-27","2020-09-28","2020-09-29","2020-09-30","2020-10-01","2020-10-02","2020-10-03"),2,
                                                                 ifelse(date %in% c("2020-10-04","2020-10-05","2020-10-06","2020-10-07","2020-10-08","2020-10-09","2020-10-10"),3,
                                                                        ifelse(date %in% c("2020-10-11","2020-10-12","2020-10-13","2020-10-14","2020-10-15","2020-10-16","2020-10-17"),4,
                                                                               ifelse(date %in% c("2020-10-18","2020-10-19","2020-10-20","2020-10-21","2020-10-22","2020-10-23","2020-10-24"),5,
                                                                                      ifelse(date %in% c("2020-10-25"),6,NA)))))))
data_order_pre$date <- as.Date(data_order_pre$date)

# 변수 만들기
test <- data_order_pre %>% filter(week %in% c(2:5)) %>%
  group_by(rider_id, week) %>%
  summarise(num_working_days = length(unique(date))) %>% 
  group_by(rider_id) %>%
  summarise(num_working_days = mean(num_working_days))

pre_var <- left_join(pre_var, test)
#hist(pre_var$num_working_days, breaks=533, main = "Avg. working days in a week", xlab="Number of working days")
#hist(pre_var$share_weekdays, breaks=533, main = "Share of working weekdays in a week", xlab="Share of weekdays")

##### 부릉 서비스 경력
data_order_pre$created_at <- as.Date(data_order_pre$created_at)
data_order_pre <- data_order_pre %>% mutate(tenure = as.numeric(as.Date("2020-10-26")-created_at))
summary(data_order_pre$tenure)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 30     121     264     337     512    1151 

test <- data_order_pre %>% group_by(rider_id) %>% summarise(tenure = unique(tenure))

pre_var <- left_join(pre_var, test)
#hist(pre_var$tenure, breaks=533, main = "Tenure in Vroong", xlab="Tenure (days)")

##### 꿀콜 레벨
test <- data_order_pre %>% group_by(rider_id) %>% summarise(avg_order_level = mean(order_level, na.rm=TRUE))
pre_var <- left_join(pre_var,test)

#hist(test$avg_order_level, breaks =300)

##### shift내 평균 주문개수, duration, shift간 idle time, 주문1개당 소요시간
test <- data_shift %>% filter(date<"2020-10-26") %>% 
  group_by(rider_id) %>% summarise(avg_assign_shift = mean(avg_assign),
                                   avg_pickup_shift = mean(avg_pickup),
                                   avg_deliver_shift = mean(avg_deliver),
                                   avg_waiting_shift = mean(avg_waiting),
                                   avg_orders_shift = mean(num_orders),
                                   avg_duration_shift = mean(total_duration),
                                   avg_idle_shift = mean(idle_btw_shifts, na.rm=T),
                                   avg_duration_orders = mean(avg_duration_orders))
pre_var <- left_join(pre_var,test)

##### 하루 평균 shift개수, 합배송 shift의 비율, 합배송 shift내 평균 주문개수, 
test <- data_day %>% filter(date<"2020-10-26") %>% 
  group_by(rider_id) %>% summarise(daily_total_shift = mean(total_shift),
                                   daily_singleorder = mean(orders_one),
                                   daily_share_singleorder = mean(orders_one/total_orders),
                                   daily_working_duration = mean(working_duration),
                                   daily_idle_duration = mean(idle_duration),
                                   daily_total_labor = mean(total_labor),
                                   daily_total_order = mean(total_orders),
                                   daily_share_idled = mean(share_idled),
                                   daily_orders_per_hour = mean(orders_per_hour),
                                   daily_profit = mean(total_fee))

pre_var <- left_join(pre_var, test)

##### Treat
pre_var$Treat <- ifelse(pre_var$rider_id %in% treat_riders$rider_id, 1, 0)

##### Proficiency
pre_var <- left_join(pre_var, proficiency)

########################################################################################################################################################
##### Matching Preparation #####
########################################################################################################################################################
library(MatchIt); library(knitr)
head(pre_var) # 앞에서 만든 라이더 특성변수 34개
summary(pre_var) #584riders, 1 NA in num_working_days(도입전 기간은 10/25하루만 근무), 1 NA in avg_idle_shift

##### Covarites #####
colnames(pre_var)
# [1] "rider_id"                "avg_assign"              "avg_pickup"              "avg_deliver"            
# [5] "avg_waiting"             "avg_ODdist"              "daily_delivered_stores"  "num_working_days"       
# [9] "tenure"                  "avg_order_level"         "avg_assign_shift"        "avg_pickup_shift"       
# [13] "avg_deliver_shift"       "avg_waiting_shift"       "avg_orders_shift"        "avg_duration_shift"     
# [17] "avg_idle_shift"          "avg_duration_orders"     "daily_total_shift"       "daily_singleorder"      
# [21] "daily_share_singleorder" "daily_working_duration"  "daily_idle_duration"     "daily_total_labor"      
# [25] "daily_total_order"       "daily_share_idled"       "daily_orders_per_hour"   "daily_profit"           
# [29] "Treat"                   "prof"                    "prof_low50"              "prof_high50"            
# [33] "prof_low"                "prof_med"                "prof_high"      
pretreat_cov <- colnames(pre_var[,c(2:28,30:35)])

pre_var_nona <- na.omit(pre_var) #582riders
pre_var_nona <- as.data.frame(pre_var_nona)

##### T-test before matching by Treat/control #####
test <- pre_var_nona %>% group_by(Treat) %>% dplyr::select(one_of(pretreat_cov)) %>%
  summarise_all(funs(mean(., na.rm=T)))

test <- data.frame(tvalue=rep(1,length(pretreat_cov)), pvalue=rep(1,length(pretreat_cov)))
for (i in 1:length(pretreat_cov)){
  a<-t.test(pre_var_nona[, pretreat_cov[i]] ~ pre_var_nona[, 'Treat'])
  test$tvalue[i] <- a$statistic
  test$pvalue[i] <- a$p.value  

##### Propensity score estimation #####
pscore <- glm(Treat ~ daily_delivered_stores + num_working_days +
                avg_waiting_shift + avg_orders_shift + avg_duration_shift + avg_idle_shift +
                daily_total_labor + daily_idle_duration, family = binomial(), data=pre_var_nona)
summary(pscore)

### 유의한 변수들 찾기
#backward step으로 유의미한 변수 일부 추리기
test <- step(pscore, direction ="backward")
summary(test)

pscore1 <- glm(Treat ~ daily_delivered_stores + num_working_days +
                 avg_waiting_shift + avg_orders_shift + avg_duration_shift + avg_idle_shift +
                 daily_total_labor + daily_idle_duration, 
               family = binomial(link = "logit"), data=pre_var_nona)
summary(pscore1)

# Save predicted propensity scrore
pscore_df <- data.frame(rider_id = pre_var_nona$rider_id,
                        pscore = predict(pscore1, type="response"),
                        Treat = pscore1$model$Treat)
head(pscore_df)

# Examining the region of common support
labs <- paste("Rider:", c("who adopt AI", "never adopt AI"))
pscore_df %>%
  mutate(Treat = ifelse(Treat==1, labs[1],labs[2])) %>%
  ggplot(aes(x=pscore)) +
  geom_histogram(color = "white", binwidth = 0.01) +
  facet_wrap(~Treat) +
  xlab("Probability of AI adoption") +
  theme_bw()

# Distribution of predicted propensity scrore
plot(density(pscore_df$pscore[pscore_df$Treat==1]), main = "Before matching", xlab = "Estimated propensity score")
lines(density(pscore_df$pscor[pre_var_nona$Treat==0]), lty=2)

################################################################################################################################################
##### #1 Matching: PSM 1:1 matching with a caplier size 0.2 (or 0.05) times the s.d. of the propensity #####
################################################################################################################################################
#psmatch1(Main result로 사용) - 1:1 nearest matching with caliper 0.05 w/o replacement
#psmatch2 - 1:1 nearest matching with caliper 0.01 w/o replacement

### matching 
psmatch1 <- matchit(Treat ~  daily_delivered_stores + num_working_days +
                      avg_waiting_shift + avg_orders_shift + avg_duration_shift + avg_idle_shift +
                      daily_total_labor + daily_idle_duration,
                    method="nearest", data=pre_var_nona, caliper=0.05, std.caliper=TRUE, discard = "both")
summary(psmatch1)

psmatch2 <- matchit(Treat ~  daily_delivered_stores + num_working_days +
                      avg_waiting_shift + avg_orders_shift + avg_duration_shift + avg_idle_shift +
                      daily_total_labor + daily_idle_duration,
                    method="nearest", data=pre_var_nona, caliper=0.01, std.caliper=TRUE, discard = "both")
summary(psmatch2)

### matched data
matched_data1 <- match.data(psmatch1)
matched_data2 <- match.data(psmatch2)

### Distribution of predicted propensity scrore
pscore_df_matched <- pscore_df %>% filter(rider_id %in% matched_data1$rider_id)

plot(density(pscore_df_matched$pscore[pscore_df_matched$Treat==0]), lty=2, main = "After matching", xlab = "Estimated propensity score")
lines(density(pscore_df_matched$pscore[pscore_df_matched$Treat==1]))
legend("topright",legend=c("Control","Treat"),lty=c(2,1))

### Machted data에 대한 T-test #####
test <- matched_data1 %>% group_by(Treat) %>% dplyr::select(one_of(pretreat_cov)) %>%
  summarise_all(funs(mean(., na.rm=T)))

test <- data.frame(tvalue=rep(1,length(pretreat_cov)), pvalue=rep(1,length(pretreat_cov)))
for (i in 1:length(pretreat_cov)){
  a<-t.test(matched_data1[, pretreat_cov[i]] ~ matched_data1[, 'Treat'])
  test$tvalue[i] <- a$statistic
  test$pvalue[i] <- a$p.value  
}

### 매칭된 샘플 데이터 추출
data_order_matched1 <- data_order %>% filter(rider_id %in% matched_data1$rider_id) %>% left_join(matched_data1[,c(1,38)])
data_shift_matched1 <- data_shift %>% filter(rider_id %in% matched_data1$rider_id) %>% left_join(matched_data1[,c(1,38)])
data_day_matched1 <- data_day %>% filter(rider_id %in% matched_data1$rider_id) %>% left_join(matched_data1[,c(1,38)])

data_shift_matched2<- data_shift %>% filter(rider_id %in% matched_data2$rider_id) %>% left_join(matched_data2[,c(1,38)])
data_day_matched2 <- data_day %>% filter(rider_id %in% matched_data2$rider_id) %>% left_join(matched_data2[,c(1,38)])

################################################################################################################################################
#### #2 PSM w/o replacement with a caplier size 0.2(0.05) of s.d. of ps score & 추천배차 단 1회 사용 라이더 제외후 매칭&분석 #####
################################################################################################################################################
#psmatch3 - caliper 0.2, 추천배차 단 1회 사용 라이더 제외
#psmatch4 - caliper 0.05, 추천배차 단 1회 사용 라이더 제외

test <- data_order %>% group_by(rider_id, prof_low, prof_med, prof_high) %>% summarise(ai_order = sum(is_rec_completed)) %>% filter(ai_order==1) 
#1회 사용라이더 61명 - prof_low 15, prof_med 23, prof_high 23명 (처치군의 15.2%)

pre_var_nona_no1 <- pre_var_nona %>% filter(rider_id %!in% test$rider_id) #521riders

### Executing matching algorithm: one-to-one matching w/o replacement with a caplier size 0.2 times the s.d. of the propensity 
psmatch3 <- matchit(Treat ~ daily_delivered_stores + num_working_days + 
                      avg_assign_shift + avg_pickup_shift + avg_deliver_shift + avg_order_level +
                      daily_orders_per_hour + daily_total_shift + daily_idle_duration,
                    method="nearest", data=pre_var_nona_no1, caliper=0.2, std.caliper=TRUE, discard = "both")
summary(psmatch4)

### matched data
matched_data <- match.data(psmatch3)

### Distribution of predicted propensity scrore
pscore_df_matched <- pscore_df %>% filter(rider_id %in% matched_data$rider_id)

plot(density(pscore_df_matched$pscore[pscore_df_matched$Treat==0]), lty=2, main = "After matching", xlab = "Estimated propensity score")
lines(density(pscore_df_matched$pscore[pscore_df_matched$Treat==1]))
legend("topright",legend=c("Control","Treat"),lty=c(2,1))

### Machted data에 대한 T-test
test <- matched_data %>% group_by(Treat) %>% dplyr::select(one_of(pretreat_cov)) %>%
  summarise_all(funs(mean(., na.rm=T)))

test <- data.frame(tvalue=rep(1,length(pretreat_cov)), pvalue=rep(1,length(pretreat_cov)))
for (i in 1:length(pretreat_cov)){
  a<-t.test(matched_data[, pretreat_cov[i]] ~ matched_data[, 'Treat'])
  test$tvalue[i] <- a$statistic
  test$pvalue[i] <- a$p.value  
}

### 매칭된 샘플 데이터 추출
data_shift_matched <- data_shift %>% filter(rider_id %in% matched_data$rider_id) %>% left_join(matched_data[,c(1,49)])
data_day_matched <- data_day %>% filter(rider_id %in% matched_data$rider_id) %>% left_join(matched_data[,c(1,49)])

################################################################################################################################################
##### #3 PSM with replacement under a caplier size 0.2 (or 0.05) times the s.d. of the propensity #####
##### (whether treated can be used as matches for more than one control individual)
################################################################################################################################################
# psmatch3: PSM with 1:1 replacement under a caplier size 0.05
# psmatch4: PSM with 1:1 replacement under a caplier size 0.01

### Treat_rev: control-treat 1:1 매칭을 위해 control==1, treat==0 배정
pre_var_nona <- pre_var_nona %>% mutate(Treat_rev = ifelse(Treat==1,0,1))

### matching algorithm
psmatch3 <- matchit(Treat_rev ~  daily_delivered_stores + num_working_days +
                      avg_waiting_shift + avg_orders_shift + avg_duration_shift + avg_idle_shift +
                      daily_total_labor + daily_idle_duration,
                    method="nearest", data=pre_var_nona, caliper=0.05, std.caliper=TRUE, replace = TRUE, discard = "both")
summary(psmatch3)

psmatch4 <- matchit(Treat_rev ~  daily_delivered_stores + num_working_days +
                      avg_waiting_shift + avg_orders_shift + avg_duration_shift + avg_idle_shift +
                      daily_total_labor + daily_idle_duration,
                    method="nearest", data=pre_var_nona, caliper=0.01, std.caliper=TRUE, replace = TRUE, discard = "both")
summary(psmatch4)


### matched data
matched_data3 <- match.data(psmatch3)
matched_data4 <- match.data(psmatch4)

### Distribution of predicted propensity scrore
pscore_df_matched <- pscore_df %>% filter(rider_id %in% matched_data$rider_id)

plot(density(pscore_df_matched$pscore[pscore_df_matched$Treat==0]), lty=2, main = "After matching", xlab = "Estimated propensity score")
lines(density(pscore_df_matched$pscore[pscore_df_matched$Treat==1]))
legend("topright",legend=c("Control","Treat"),lty=c(2,1))

## Machted data에 대한 T-test
test <- matched_data %>% group_by(Treat) %>% dplyr::select(one_of(pretreat_cov)) %>%
  summarise_all(funs(mean(., na.rm=T)))

test <- data.frame(tvalue=rep(1,length(pretreat_cov)), pvalue=rep(1,length(pretreat_cov)))
for (i in 1:length(pretreat_cov)){
  a<-t.test(matched_data[, pretreat_cov[i]] ~ matched_data[, 'Treat'])
  test$tvalue[i] <- a$statistic
  test$pvalue[i] <- a$p.value  
}

### 매칭된 샘플 데이터 추출
data_shift_matched3 <- data_shift %>% filter(rider_id %in% matched_data3$rider_id)
data_day_matched3 <- data_day %>% filter(rider_id %in% matched_data3$rider_id)

data_shift_matched4 <- data_shift %>% filter(rider_id %in% matched_data4$rider_id)
data_day_matched4 <- data_day %>% filter(rider_id %in% matched_data4$rider_id)

################################################################################################################################################
##### #4 PSM 1:n matching #####
################################################################################################################################################
#psmatch5: PSM 1:2 matching w/ replacement, caliper 0.05
#psmatch6: PSM 1:2 matching w/ replacement, caliper 0.01

### matching algorithm
psmatch5 <- matchit(Treat_rev ~  daily_delivered_stores + num_working_days +
                      avg_waiting_shift + avg_orders_shift + avg_duration_shift + avg_idle_shift +
                      daily_total_labor + daily_idle_duration,
                    method="nearest", data=pre_var_nona, caliper=0.05, std.caliper=TRUE, discard = "both", ratio = 2, replace = TRUE)
summary(psmatch5)

psmatch6 <- matchit(Treat_rev ~  daily_delivered_stores + num_working_days +
                      avg_waiting_shift + avg_orders_shift + avg_duration_shift + avg_idle_shift +
                      daily_total_labor + daily_idle_duration,
                    method="nearest", data=pre_var_nona, caliper=0.01, std.caliper=TRUE, discard = "both", ratio = 2, replace = TRUE)
summary(psmatch6)

### matched data
matched_data5 <- match.data(psmatch5)
matched_data6 <- match.data(psmatch6)

### Distribution of predicted propensity scrore
pscore_df_matched <- pscore_df %>% filter(rider_id %in% matched_data$rider_id)

plot(density(pscore_df_matched$pscore[pscore_df_matched$Treat==0]), lty=2, main = "After matching", xlab = "Estimated propensity score")
lines(density(pscore_df_matched$pscore[pscore_df_matched$Treat==1]))

### Machted data에 대한 T-test
test <- matched_data %>% group_by(Treat) %>% dplyr::select(one_of(pretreat_cov)) %>%
  summarise_all(funs(mean(., na.rm=T)))

test <- data.frame(tvalue=rep(1,length(pretreat_cov)), pvalue=rep(1,length(pretreat_cov)))
for (i in 1:length(pretreat_cov)){
  a<-t.test(matched_data[, pretreat_cov[i]] ~ matched_data[, 'Treat'])
  test$tvalue[i] <- a$statistic
  test$pvalue[i] <- a$p.value  
}
### 매칭된 샘플 데이터 추출
data_order_matched5 <- data_order %>% filter(rider_id %in% matched_data5$rider_id) %>% left_join(matched_data1[,c(1,42)])
data_shift_matched5 <- data_shift %>% filter(rider_id %in% matched_data5$rider_id) %>% left_join(matched_data5[,c(1,41)])
data_day_matched5 <- data_day %>% filter(rider_id %in% matched_data5$rider_id) %>% left_join(matched_data5[,c(1,41)])

data_shift_matched6 <- data_shift %>% filter(rider_id %in% matched_data6$rider_id) %>% left_join(matched_data6[,c(1,41)])
data_day_matched6 <- data_day %>% filter(rider_id %in% matched_data6$rider_id) %>% left_join(matched_data6[,c(1,41)])

################################################################################################################################################
##### # Mahalanobis matching #####
################################################################################################################################################
#psmatch7,8: Mahalonobis matching with caliper 0.05/0.01

### matching algorithm
psmatch7 <- matchit(Treat ~  daily_delivered_stores + num_working_days +
                      avg_waiting_shift + avg_orders_shift + avg_duration_shift + avg_idle_shift +
                      daily_total_labor + daily_idle_duration,
                    method="nearest", data=pre_var_nona, caliper=0.05, std.caliper=TRUE, discard = "both",
                    mahvars = ~ daily_delivered_stores + num_working_days +
                      avg_waiting_shift + avg_orders_shift + avg_duration_shift + avg_idle_shift +
                      daily_total_labor + daily_idle_duration)
summary(psmatch7)

psmatch8 <- matchit(Treat ~  daily_delivered_stores + num_working_days +
                      avg_waiting_shift + avg_orders_shift + avg_duration_shift + avg_idle_shift +
                      daily_total_labor + daily_idle_duration,
                    method="nearest", data=pre_var_nona, caliper=0.01, std.caliper=TRUE, discard = "both",
                    mahvars = ~ daily_delivered_stores + num_working_days +
                      avg_waiting_shift + avg_orders_shift + avg_duration_shift + avg_idle_shift +
                      daily_total_labor + daily_idle_duration)
summary(psmatch8)


### matched data
matched_data7 <- match.data(psmatch7)
matched_data8 <- match.data(psmatch8)

### Distribution of predicted propensity scrore
pscore_df_matched <- pscore_df %>% filter(rider_id %in% matched_data$rider_id)

plot(density(pscore_df_matched$pscore[pscore_df_matched$Treat==0]), lty=2, main = "After matching", xlab = "Estimated propensity score")
lines(density(pscore_df_matched$pscore[pscore_df_matched$Treat==1]))

### Machted data에 대한 T-test
test <- matched_data %>% group_by(Treat) %>% dplyr::select(one_of(pretreat_cov)) %>%
  summarise_all(funs(mean(., na.rm=T)))

test <- data.frame(tvalue=rep(1,length(pretreat_cov)), pvalue=rep(1,length(pretreat_cov)))
for (i in 1:length(pretreat_cov)){
  a<-t.test(matched_data[, pretreat_cov[i]] ~ matched_data[, 'Treat'])
  test$tvalue[i] <- a$statistic
  test$pvalue[i] <- a$p.value  
}

### 매칭된 샘플 데이터 추출
data_shift_matched7 <- data_shift %>% filter(rider_id %in% matched_data7$rider_id) %>% left_join(matched_data7[,c(1,39)])
data_day_matched7 <- data_day %>% filter(rider_id %in% matched_data7$rider_id) %>% left_join(matched_data7[,c(1,39)])

data_shift_matched8 <- data_shift %>% filter(rider_id %in% matched_data8$rider_id) %>% left_join(matched_data8[,c(1,39)])
data_day_matched8 <- data_day %>% filter(rider_id %in% matched_data8$rider_id) %>% left_join(matched_data8[,c(1,39)])

################################################################################################################################################
##### DID, DDD model estimation #####
################################################################################################################################################

##### shift-level data로 분석 ###################
### 매칭 방법별로 DID 시행
m1 <- felm(num_orders ~ After:Treat | rider_id + station_date + hourDOW | 0 | rider_id, data=data_shift_matched1)
#m2 <- felm(num_orders ~ After:Treat | rider_id + station_date | 0 | rider_id, data=data_day_matched2)
m3 <- felm(num_orders ~ After:Treat | rider_id + station_date + hourDOW | 0 | rider_id, data=data_shift_matched3)
m4 <- felm(avg_duration_orders ~ After:Treat | rider_id + station_date | 0 | rider_id, data=data_shift_matched4)
m5 <- felm(num_orders ~ After:Treat | rider_id + station_date + hourDOW | 0 | rider_id, data=data_shift_matched5)
m6 <- felm(avg_duration_orders ~ After:Treat | rider_id + station_date | 0 | rider_id, data=data_shift_matched6)
m7 <- felm(num_orders ~ After:Treat | rider_id + station_date + hourDOW | 0 | rider_id, data=data_shift_matched7)
#m8 <- felm(num_orders ~ After:Treat | rider_id + station_date | 0 | rider_id, data=data_day_matched8)
m9 <- felm(num_orders ~ After:Treat | rider_id + station_date + hourDOW | 0 | rider_id, data=data_shift)

### 결과비교
tab_model(m1,m3,m5,m7,m9,
          df.method = "wald",
          show.ci = F, show.se = T, collapse.se = T, show.ngroups = F, show.r2 = T,
          p.threshold = c(0.1, 0.05, 0.01), p.style = "stars",
          digits=3)
tab_model(m4,m6,
          df.method = "wald",
          show.ci = F, show.se = T, collapse.se = T, show.ngroups = F, show.r2 = T,
          p.threshold = c(0.1, 0.05, 0.01), p.style = "stars",
          digits=3)

### 매칭 방법별로 DDD 시행
m1 <- felm(num_orders ~ After:Treat:prof_low + After:Treat:prof_med  + After:Treat:prof_high +
             After:prof_med + After:prof_high | rider_id + station_date + hourDOW | 0 | rider_id, data=data_shift_matched1)
m1 <- felm( ~ After:Treat:prof_low + After:Treat:prof_med  + After:Treat:prof_high +
              After:prof_med + After:prof_high | rider_id + station_date + hourDOW | 0 | rider_date, data=data_shift_matched1)
#m2 <- felm(avg_waiting ~ After:Treat:prof_low + After:Treat:prof_med + After:Treat:prof_high + 
#             After:prof_med + After:prof_high + avg_dist | rider_id + station_date + hourDOW | 0 | rider_id, data=data_shift_matched2)
m3 <- felm(ln(avg_dist) ~ After:Treat:prof_low + After:Treat:prof_med + After:Treat:prof_high + 
             After:prof_med + After:prof_high | rider_id + station_date + hourDOW | 0 | rider_id, data=data_shift_matched3)
m4 <- felm(ln(avg_dist) ~ After:Treat:prof_low + After:Treat:prof_med + After:Treat:prof_high + 
             After:prof_med + After:prof_high | rider_id + station_date + hourDOW | 0 | rider_id, data=data_shift_matched4)
m5 <- felm(ln(avg_dist) ~ After:Treat:prof_low + After:Treat:prof_med + After:Treat:prof_high + 
             After:prof_med + After:prof_high | rider_id + station_date + hourDOW | 0 | rider_id, data=data_shift_matched5)
m6 <- felm(ln(avg_dist) ~ After:Treat:prof_low + After:Treat:prof_med + After:Treat:prof_high + 
             After:prof_med + After:prof_high | rider_id + station_date + hourDOW | 0 | rider_id, data=data_shift_matched6)
m7 <- felm(ln(avg_dist) ~ After:Treat:prof_low + After:Treat:prof_med + After:Treat:prof_high + 
             After:prof_med + After:prof_high | rider_id + station_date + hourDOW | 0 | rider_id, data=data_shift_matched7)
#m8 <- felm(avg_waiting ~ After:Treat:prof_low + After:Treat:prof_med + After:Treat:prof_high + 
#             After:prof_med + After:prof_high + avg_dist | rider_id + station_date + hourDOW | 0 | rider_id, data=data_shift_matched8)
m9 <- felm(ln(avg_dist) ~ After:Treat:prof_low + After:Treat:prof_med + After:Treat:prof_high + 
             After:prof_med + After:prof_high | rider_id + station_date + hourDOW | 0 | rider_id, data=data_shift)

tab_model(m1,m3,m5,m7,m9,
          df.method = "wald",
          show.ci = F, show.se = T, collapse.se = T, show.ngroups = F, show.r2 = T,
          p.threshold = c(0.1, 0.05, 0.01), p.style = "stars",
          digits=3,
          rm.terms = c("After:prof_med", "After:prof_high"))
tab_model(m4,m6,
          df.method = "wald",
          show.ci = F, show.se = T, collapse.se = T, show.ngroups = F, show.r2 = T,
          p.threshold = c(0.1, 0.05, 0.01), p.style = "stars",
          digits=3,
          rm.terms = c("After:prof_med", "After:prof_high"))


##### day-level data로 분석 ###################
### 매칭 방법별로 DID 시행
m1 <- felm(ln(orders_per_hour) ~ After:Treat | rider_id + station_date | 0 | rider_id, data=data_day_matched7)
m1 <- felm(orders_per_hour ~ After:Treat | rider_id + station_date | 0 | v, data=data_day_matched1)
#m2 <- felm(share_idled ~ After:Treat | rider_id + station_date | 0 | rider_id, data=data_day_matched2)
m3 <- felm(share_idled ~ After:Treat | rider_id + station_date | 0 | rider_id, data=data_day_matched3)
m4 <- felm(share_idled ~ After:Treat | rider_id + station_date | 0 | rider_id, data=data_day_matched4)
m5 <- felm(share_idled ~ After:Treat | rider_id + station_date | 0 | rider_id, data=data_day_matched5)
m6 <- felm(share_idled ~ After:Treat | rider_id + station_date | 0 | rider_id, data=data_day_matched6)
m7 <- felm(share_idled ~ After:Treat | rider_id + station_date | 0 | rider_id, data=data_day_matched7)
#m8 <- felm(avg_waiting ~ After:Treat | rider_id + station_date | 0 | rider_id, data=data_day_matched8)
m9 <- felm(share_idled ~ After:Treat | rider_id + station_date | 0 | rider_id, data=data_day)

tab_model(m1,m3,m5,m7,m9,
          df.method = "wald",
          show.ci = F, show.se = T, collapse.se = T, show.ngroups = F, show.r2 = T,
          p.threshold = c(0.1, 0.05, 0.01), p.style = "stars",
          digits=3)
tab_model(m4,m6,
          df.method = "wald",
          show.ci = F, show.se = T, collapse.se = T, show.ngroups = F, show.r2 = T,
          p.threshold = c(0.1, 0.05, 0.01), p.style = "stars",
          digits=3)
tab_model(m1,m3,m4,m5,m6,m7,m9,
          df.method = "wald",
          show.ci = F, show.se = T, collapse.se = T, show.ngroups = F, show.r2 = T,
          p.threshold = c(0.1, 0.05, 0.01), p.style = "stars",
          digits=3)

### 매칭 방법별로 DDD 시행
m1 <- felm(ln(orders_per_hour) ~ After:Treat:prof_low + After:Treat:prof_med + After:Treat:prof_high +
             After:prof_med + After:prof_high | rider_id + station_date | 0 | rider_date, data=data_day_matched1)
#m2 <- felm(orders_per_hour ~ After:Treat:prof_low + After:Treat:prof_med + After:Treat:prof_high + 
#             After:prof_med + After:prof_high | rider_id + station_date | 0 | rider_id, data=data_day_matched2)
m3 <- felm(orders_per_hour ~ After:Treat + After:Treat:prof_med + After:Treat:prof_high + 
             After:prof_med + After:prof_high | rider_id + station_date | 0 | rider_id, data=data_day_matched3)
m4 <- felm(orders_per_hour ~ After:Treat + After:Treat:prof_med + After:Treat:prof_high + 
             After:prof_med + After:prof_high | rider_id + station_date | 0 | rider_id, data=data_day_matched4)
m5 <- felm(orders_per_hour ~ After:Treat + After:Treat:prof_med + After:Treat:prof_high + 
             After:prof_med + After:prof_high | rider_id + station_date | 0 | rider_id, data=data_day_matched5)
m6 <- felm(orders_per_hour ~ After:Treat + After:Treat:prof_med + After:Treat:prof_high + 
             After:prof_med + After:prof_high | rider_id + station_date | 0 | rider_id, data=data_day_matched6)
m7 <- felm(orders_per_hour ~ After:Treat + After:Treat:prof_med + After:Treat:prof_high + 
             After:prof_med + After:prof_high | rider_id + station_date | 0 | rider_id, data=data_day_matched7)
#m8 <- felm(orders_per_hour ~ After:Treat:prof_low + After:Treat:prof_med + After:Treat:prof_high + 
#             After:prof_med + After:prof_high | rider_id + station_date | 0 | rider_id, data=data_day_matched8)
m9 <- felm(orders_per_hour ~ After:Treat + After:Treat:prof_med + After:Treat:prof_high + 
             After:prof_med + After:prof_high | rider_id + station_date | 0 | rider_id, data=data_day)

tab_model(m1,m3,m5,m7,m9,
          df.method = "wald",
          show.ci = F, show.se = T, collapse.se = T, show.ngroups = F, show.r2 = T,
          p.threshold = c(0.1, 0.05, 0.01), p.style = "stars",
          digits=3,
          rm.terms = c("After:prof_med", "After:prof_high"))
tab_model(m4,m6,
          df.method = "wald",
          show.ci = F, show.se = T, collapse.se = T, show.ngroups = F, show.r2 = T,
          p.threshold = c(0.1, 0.05, 0.01), p.style = "stars",
          digits=3,
          rm.terms = c("After:prof_med", "After:prof_high"))
tab_model(m1,m3,m5,m7,m4,m6,m9,
          df.method = "wald",
          show.ci = F, show.se = T, collapse.se = T, show.ngroups = F, show.r2 = T,
          p.threshold = c(0.1, 0.05, 0.01), p.style = "stars",
          digits=3,
          rm.terms = c("After:prof_med", "After:prof_high"))


##### Single-order delivery, stacked-order delivery 나눠서 분석 ###########
### single order
test<-data_shift_matched1 %>% filter(num_orders==1)

model <- felm(avg_waiting ~ After:Treat + avg_dist | rider_id + station_date + hourDOW | 0 | rider_id, data=test)
summary(model)

model <- felm(avg_waiting ~ After:Treat + After:Treat:prof_med + After:Treat:prof_high + 
                After:prof_med + After:prof_high + avg_dist | rider_id + station_date + hourDOW | 0 | rider_id, data=test)
summary(model)

### stacked order
test<-data_shift_matched1 %>% filter(num_orders>1)
model <- felm(avg_waiting ~ After:Treat:prof_low + After:Treat:prof_med + After:Treat:prof_high + 
                After:prof_med + After:prof_high + avg_dist | rider_id + station_date + hourDOW | 0 | rider_id, data=test)
summary(model)

################################################################################################################################################
##### DID, DDD model estimation - 주별 효과 분석 #####
################################################################################################################################################
head(data_day_matched)

model <- felm(orders_per_hour ~ Treat:wb5 + Treat:wb4 + Treat:wb3 + Treat:wb2 +
                Treat:w1 + Treat:w2 + Treat:w3 + Treat:w4 + Treat:w5 + Treat:w6 | rider_id + station_date  | 0 | rider_id, data=data_day_matched1)
summary(model)
model <- felm(total_labor~ Treat:wb5:prof_low + Treat:wb4:prof_low + Treat:wb3:prof_low + Treat:wb2:prof_low + 
                Treat:w1:prof_low + Treat:w2:prof_low + Treat:w3:prof_low + Treat:w4:prof_low + Treat:w5:prof_low + 
                Treat:wb5:prof_med + Treat:wb4:prof_med + Treat:wb3:prof_med + Treat:wb2:prof_med + 
                Treat:w1:prof_med + Treat:w2:prof_med  + Treat:w3:prof_med  + Treat:w4:prof_med  + Treat:w5:prof_med  + 
                Treat:wb5:prof_high + Treat:wb4:prof_high + Treat:wb3:prof_high + Treat:wb2:prof_high + 
                Treat:w1:prof_high + Treat:w2:prof_high  + Treat:w3:prof_high  + Treat:w4:prof_high  + Treat:w5:prof_high  +
                wb5:prof_med + wb4:prof_med + wb3:prof_med + wb2:prof_med + 
                w1:prof_med + w2:prof_med + w3:prof_med + w4:prof_med + w5:prof_med + 
                wb5:prof_high + wb4:prof_high + wb3:prof_high + wb2:prof_high + 
                w1:prof_high + w2:prof_high + w3:prof_high + w4:prof_high + w5:prof_high | rider_id + station_date  | 0 | rider_id, data=data_day_matched1)
summary(model)

