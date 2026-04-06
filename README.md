# IJIM Paper Revision: AI Task Assignment in Food Delivery

IJIM(International Journal of Information Management) Major Revision 대응 프로젝트.

**논문**: "Does AI Benefit All Platform Stakeholders? Evidence from Algorithmic Task Assignment in Food Delivery"

## Quick Start

### 1. 데이터 다운로드
```bash
# recommendation_data_20201221.csv (2.3GB, 부산 데이터) → data/riders_full.csv로 저장
# https://drive.google.com/file/d/19FE0hJRydMI_y61OhaB4ehXlWlGiwvO4/view?usp=sharing

# recommendation_data_2023.csv (1.75GB, 부산 외 지역) → data/new_data.csv로 저장
# https://drive.google.com/file/d/19-U33XcXVPfKHEyEz_p-6ZP03wz5kTR2/view?usp=sharing
```

### 2. R 환경 설정
```r
install.packages(c("data.table", "dplyr", "fixest", "lfe", "MatchIt",
                    "sensemakr", "ggplot2", "cowplot", "lubridate"))
```

### 3. 분석 실행
```bash
Rscript code/00_data_preparation.R   # 전처리 (약 45초)
Rscript code/02_event_study.R        # Event-study (핵심)
Rscript code/03_oster_bounds.R       # Oster bounds
# ... 나머지 분석은 CLAUDE.md 참조
```

## Project Structure

```
├── manuscript/          # 원고 + 리뷰 + Response letter 초안
├── code/                # R 분석 코드 (원본 2개 + 신규 8개)
├── data/                # 데이터 (대용량은 gitignore, Drive 다운로드)
├── output/              # 분석 결과 (표 + 그림 + 해석)
├── docs/                # 수정 전략 문서 (한글)
└── CLAUDE.md            # Claude Code용 프로젝트 컨텍스트
```

## Key Documents

| 목적 | 파일 |
|------|------|
| **수정 지침** (뭘 어떻게 고칠지) | `docs/20-revision-guide.md` |
| **Response letter** (리뷰어 대응) | `manuscript/response-letter.md` |
| **전체 상황 개요** | `docs/00-situation-overview.md` |
| **비타협 이슈 9개** | `docs/01-convergence-map.md` |
| **분석 결과 해석** | `output/interpretation/*.md` |
| **팩트체크 결과** | `docs/11-fact-check.md` |
| **신규 인용 18개** | `docs/12-new-references.md` |

## Analysis Results Summary

| Analysis | Key Result | Reviewer Issue |
|----------|-----------|---------------|
| Event-study (1mo) | F=1.41, p=0.229 (parallel trends OK) | R1-3A, C2 |
| Event-study (extended) | F=0.475, p=0.853 (stronger) | R1-3A, C2, C6 |
| Oster bounds | \|delta*\|=1.25 > 1 (robust) | R1-3C, R2-7 |
| Gini/Theil | 0.181 -> 0.152 (inequality decreased) | R1-M2 |
| Stable workers | Consistent with full sample | R1-3C |
| Learning dynamics | Positive trend (corr=0.48) | R2-9 |
| Dose-response | Non-monotonic (caution needed) | R1-3B |

## Revision Workflow

1. `docs/20-revision-guide.md` 읽기 — 지적별 수정 방향 확인
2. `output/` 분석 결과 확인 — 근거 자료
3. 원고 수정 (저자 작업)
4. `manuscript/response-letter.md` 기반 Response letter 작성
5. 제출 (마감: 2026-05-30)

## Data Files

| 파일명 | 설명 | 크기 | 소스 |
|--------|------|------|------|
| `riders_full.csv` | recommendation_data_20201221.csv (부산, 2019-04~2020-11) | 2.3GB | [Drive](https://drive.google.com/file/d/19FE0hJRydMI_y61OhaB4ehXlWlGiwvO4/view?usp=sharing) |
| `new_data.csv` | recommendation_data_2023.csv (부산 외, 2020-07~2021-01) | 1.75GB | [Drive](https://drive.google.com/file/d/19-U33XcXVPfKHEyEz_p-6ZP03wz5kTR2/view?usp=sharing) |
| (미보유) | recommendation_data_busan_exclusive_dec_feb.csv | - | 부산 12-2월 확장 시 필요 |
