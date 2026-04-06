# Oster (2019) Bounds 분석 결과

## 대응 리뷰어 지적: R1-3C, R2-7

## 방법론
- Oster, E. (2019). Unobservable Selection and Coefficient Stability. JBES, 37(2), 187-204.
- R_max = min(1, 1.3 × R²_long) = 0.0128
- δ* = β_long × (R_max - R²_long) / [(β_short - β_long) × (R²_long - R²_short)]

## 결과
- β (비통제): -0.2073 (R² = 2e-04)
- β (통제): -0.2744 (R² = 0.0098)
- δ* = -1.2491
- 판단: 강건 (|δ*| > 1)

## 코드: code/03_oster_bounds.R
## 산출물: output/tables/oster_bounds.csv

