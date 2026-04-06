# Event-Study 분석 결과 해석

## 대응 리뷰어 지적: R1-3A, C2

## 방법론
- 모형: 동적 DID (fixest::feols)
- 종속변수: orders_per_hour (시간당 주문 수)
- 고정효과: rider_id, station_date (지점×날짜)
- 군집 표준오차: rider_id 수준
- 기준 기간: 도입 직전 주 (rel_week = -1)
- 참고: Angrist & Pischke (2009) Mostly Harmless Econometrics; Sun & Abraham (2021) 동적 DID

## 사전 추세 검증
- 결합 F-검정 통계량: 1.408
- p-value: 0.2294
- 판단: 병행 추세 가정 지지 (p > 0.10)

## GO/NO-GO 판단: GO

## 코드
- code/02_event_study.R

## 산출물
- output/figures/event_study_productivity.png
- output/tables/event_study_coefficients.csv

