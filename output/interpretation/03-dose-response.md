# 용량-반응 분석 결과

## 대응: R1-3B

## 방법론
- AIShare = (AI 배정 주문) / (사후 전체 주문) per rider
- 연속형 + 사분위 구간 명세
- FE: rider_id, station_date. Cluster: rider_id

## 결과
- 연속형 β: -0.3604
- Q1(low): -0.2281
- Q2(mid): -1.7072
- Q3(high): -0.1777
- 단조성: 비단조

## 코드: code/04_dose_response.R
## 산출물: output/tables/dose_response_quartiles.csv, output/figures/dose_response.png

