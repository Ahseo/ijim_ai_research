# IJIM Paper Revision Project

## Project Context

IJIM(International Journal of Information Management) 제출 논문 "Does AI Benefit All Platform Stakeholders?" 의 Major Revision 대응 프로젝트.

- Manuscript #: JJIM-D-25-02826
- Deadline: 2026-05-30
- Editor: Michael Chau
- Decision: R&R (Major Revision)

## Repository Structure

```
ijim_ai_research/
├── CLAUDE.md                    # 이 파일 - 프로젝트 컨텍스트
├── README.md                    # 프로젝트 개요 + 사용법
│
├── manuscript/                  # 원고 관련
│   ├── Algorithmic task assignment_manuscript_final.docx  # 원본 원고
│   ├── review.docx              # 리뷰어/AE 코멘트 원본
│   └── response-letter.md       # Response letter 초안 (영어)
│
├── code/                        # R 분석 코드
│   ├── data preparation_231001.r    # [원본] 저자의 전처리 코드 (수정 금지)
│   ├── data analysis_231001.r       # [원본] 저자의 분석 코드 (수정 금지)
│   ├── 00_data_preparation.R        # [신규] 전처리 파이프라인
│   ├── 01_reproduce_results.R       # [신규] 기존 결과 재현
│   ├── 02_event_study.R             # [신규] Event-study / 동적 DID
│   ├── 03_oster_bounds.R            # [신규] Oster (2019) bounds
│   ├── 04_dose_response.R           # [신규] 용량-반응 분석
│   ├── 05_stable_workers.R          # [신규] 안정 근로자 하위표본
│   ├── 06_inequality.R              # [신규] Gini/Theil 불평등 분해
│   └── 07_learning_dynamics.R       # [신규] 기간 내 학습 역학
│
├── data/                        # 데이터 (대용량 파일은 gitignore)
│   ├── riders_full.csv          # [gitignore] 주문 데이터 2.3GB - Google Drive에서 다운로드
│   ├── rider_info.csv           # 라이더 정보
│   ├── riders_2023.csv          # 라이더 추가 정보
│   └── processed/               # [gitignore] 전처리 결과 - R 코드 실행 시 자동 생성
│
├── output/                      # 분석 결과
│   ├── tables/                  # CSV 표 (11개)
│   ├── figures/                 # PNG 그림 (3개, 영어)
│   └── interpretation/          # 분석별 해석 문서 (6개)
│
└── docs/                        # 수정 전략 문서 (한글)
    ├── 00-situation-overview.md  # 전체 상황 개요
    ├── 01-convergence-map.md    # 비타협 이슈 9개
    ├── 02-severity-matrix.md    # 심각도 x 실현가능성 매트릭스
    ├── 03-revision-roadmap.md   # 최우선 액션 Top 10
    ├── 04-new-analyses.md       # 필요 통계 분석 (수식 포함)
    ├── 05-ai-vs-dispatch.md     # AI vs 알고리즘 디스패치 프레이밍
    ├── 06-terminology-reframing.md  # Skill → Proficiency 전환
    ├── 07-identification-strategy.md # 식별 전략 개선
    ├── 08-response-letter.md    # Response letter 설계도
    ├── 09-paper-architecture.md # 수정 논문 구조
    ├── 10-execution-plan.md     # 실행 계획 Phase 0-5
    ├── 11-fact-check.md         # 핵심 논문 팩트체크 결과
    ├── 12-new-references.md     # 신규 인용 18개
    └── 20-revision-guide.md     # 지적별 수정 지침서 (핵심 문서)
```

## Key Rules

### DO NOT modify
- `code/data preparation_231001.r` — 저자 원본 전처리 코드
- `code/data analysis_231001.r` — 저자 원본 분석 코드
- `manuscript/Algorithmic task assignment_manuscript_final.docx` — 원본 원고
- `manuscript/review.docx` — 리뷰 원본
- `data/riders_full.csv` — 원본 데이터 (읽기만)

### Working with data
- `data/riders_full.csv`는 2.3GB. gitignore됨. Google Drive에서 다운로드 필요:
  https://drive.google.com/file/d/19FE0hJRydMI_y61OhaB4ehXlWlGiwvO4/view?usp=sharing
- `data/processed/`는 `code/00_data_preparation.R` 실행 시 자동 생성됨
- R 4.5+ 필요. 패키지: data.table, dplyr, fixest, lfe, MatchIt, sensemakr, ggplot2, cowplot, lubridate

### Working with analyses
- 모든 R 코드는 `setwd("프로젝트루트")` 기준으로 실행
- 신규 분석 추가 시 `code/0X_분석명.R` 패턴 유지
- 결과는 반드시 `output/tables/`, `output/figures/`, `output/interpretation/`에 저장
- 그림은 영어로 생성 (한글 폰트 문제)

### Working with revision documents
- `docs/20-revision-guide.md`가 핵심 문서 — 모든 지적사항별 수정 지침
- `manuscript/response-letter.md`는 Response letter 초안
- 수정 시 `docs/` 파일들을 참조하여 일관성 유지

## Review Situation Summary

### Reviewer Assessment
- **AE**: 매우 부정적 ("immature state"), 그러나 R&R 결정
- **R1**: 건설적, 데이터셋의 가치 인정, 구체적 보강 요청
- **R2**: 부정적, 전 섹션 대폭 수정 요구

### 9 Convergence Issues (Must Fix)
1. C1: "Skill" → "Proficiency" 용어 전환
2. C2: Self-selection / 내생성 (event-study, Oster로 대응 완료)
3. C3: 소비자 측 주장 범위 축소
4. C4: AI vs 알고리즘 디스패치 구분 명시
5. C5: 사회적 평등 주장 축소 → "진보적 분배 결과"
6. C6: 관찰 기간 짧음 인정 + 검정력 분석
7. C7: 연구 목적 3개 RQ로 명확화
8. C8: 결론/한계점/시사점 섹션 추가
9. C9: 문헌 리뷰 비판적 종합으로 재구성

### Completed Analyses
| Analysis | Result | File |
|----------|--------|------|
| Event-study | F=1.41, p=0.229, parallel trends supported | output/tables/event_study_coefficients.csv |
| Oster bounds | \|delta*\|=1.25 > 1, robust | output/tables/oster_bounds.csv |
| Dose-response | Non-monotonic (interpret with caution) | output/tables/dose_response_quartiles.csv |
| Stable workers | beta=0.003, within full-sample CI | output/tables/stable_workers.csv |
| Gini/Theil | Gini 0.181->0.152, inequality decreased | output/tables/inequality_metrics.csv |
| Learning dynamics | correlation 0.48, week 4 effect increasing | output/tables/learning_dynamics.csv |

### Known Data Limitation
- `riders_full.csv`는 원본 3개 데이터 파일 중 1개. 나머지 2개 없음:
  - recommendation_data_2023.csv (8.6M rows)
  - recommendation_data_busan_exclusive_dec_feb.csv (13.5M rows)
- 이로 인해 기존 결과 정확한 재현 불가 (방향은 유사하나 계수 크기 차이)
- 신규 분석(event-study 등)은 현재 데이터로 유효

## How to Modify

### 분석 수정/추가
1. `code/` 폴더에 새 R 스크립트 추가
2. `Rscript code/0X_새분석.R` 실행
3. 결과를 `output/`에 저장
4. `output/interpretation/`에 해석 문서 추가
5. `docs/20-revision-guide.md`에 해당 분석과 리뷰어 지적 매핑 추가

### 수정 지침 변경
1. `docs/20-revision-guide.md` 수정 — 핵심 수정 지침서
2. `manuscript/response-letter.md` 업데이트 — 대응 내용 반영

### 문헌 추가
1. `docs/12-new-references.md`에 인용 추가 (저자, 연도, 저널, 발견, 삽입 위치)
2. `docs/20-revision-guide.md`의 해당 섹션에 참조 추가

### 전체 분석 재실행
```bash
# 1. 데이터 다운로드 (최초 1회)
# Google Drive에서 riders_full.csv 다운로드 → data/ 폴더에 배치

# 2. 전처리
Rscript code/00_data_preparation.R

# 3. 분석 (순서대로 또는 02 이후 병렬 가능)
Rscript code/01_reproduce_results.R
Rscript code/02_event_study.R
Rscript code/03_oster_bounds.R
Rscript code/04_dose_response.R
Rscript code/05_stable_workers.R
Rscript code/06_inequality.R
Rscript code/07_learning_dynamics.R
```
