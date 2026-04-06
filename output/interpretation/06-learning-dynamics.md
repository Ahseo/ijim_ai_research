# 기간 내 학습 역학 분석 결과

## 대응: R2-9

## 방법론: 사후 기간 주차별 처리 효과 추정
- 모형: Y = Σ β_w(Treat × Week_w) + FE + ε
- FE: rider_id, station_date. Cluster: rider_id

## 결과
- Week 1: β = 0.0792 (p = 0.3741)
- Week 2: β = -0.0279 (p = 0.7549)
- Week 3: β = -0.0645 (p = 0.4701)
- Week 4: β = 0.2842 (p = 0.4072)
- 시간-효과 상관: 0.477
- 판단: 학습 효과 시사

## 코드: code/07_learning_dynamics.R
## 산출물: output/tables/learning_dynamics.csv

