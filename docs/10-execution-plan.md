# 전체 실행 계획

## 최종 산출물

| 산출물 | 형식 | 설명 |
|--------|------|------|
| 수정 원고 초안 | Markdown → DOCX 변환 | 전 섹션 수정본 (서론~결론, 표/그림 포함) |
| Response letter | Markdown → DOCX 변환 | AE + R1 + R2 전체 대응 |
| 신규 분석 결과 | 표(CSV) + 그림(PNG/PDF) | Event-study, Oster, 용량-반응, Gini 등 |
| 분석 코드 | Python/R | 재현 가능한 전체 분석 파이프라인 |
| 참고문헌 목록 | BibTeX/텍스트 | 신규 인용 15-20개 포함 |

**최종 제출은 저자가 DOCX/LaTeX로 저널 템플릿에 맞춰 마무리해야 함.** 내가 만드는 건 내용이 완성된 초안 + 모든 분석 결과.

---

## Phase 0: 사전 준비 (1-2일)

### 0-1. 데이터 파이프라인 구축
- **할 일**: 기존 R 코드(`data preparation_231001.r`)의 핵심 로직을 Python으로 재현
- **이유**: 2.3GB 데이터를 효율적으로 처리하기 위해 polars/pandas 사용
- **구체적 작업**:
  - [ ] 원본 데이터(riders_full.csv) → 부산 지역 필터링
  - [ ] 라이더/상점/지점 정보 merge
  - [ ] 시간 변수 생성 (submitted_at → 배차/픽업/배달 소요시간)
  - [ ] 스택(shift) 단위 집계
  - [ ] 일(day) 단위 집계
  - [ ] AI 채택자(Treat) / 비채택자(Control) 식별
  - [ ] 숙련도(proficiency) 3분위 분류
- **산출물**: `code/data_preparation.py`, 전처리된 분석용 데이터셋
- **도구**: Python polars/pandas
- **실행 가능 여부**: ✅ R 코드 전문 파악 완료, 데이터 구조 확인 완료

### 0-2. 기존 분석 재현 검증
- **할 일**: 논문의 주요 결과(Table 4-7)를 재현하여 데이터-코드 정합성 확인
- **이유**: 신규 분석 전에 기존 결과가 재현되는지 확인해야 함
- **산출물**: 재현 결과 비교표
- **실행 가능 여부**: ✅ DID/DDD 회귀, PSM 매칭 모두 Python(linearmodels, causalinference)이나 R(lfe, MatchIt)로 가능

---

## Phase 1: 핵심 신규 분석 (1-2주)

### 1-1. Event-Study / 동적 DID ⭐ GO/NO-GO 관문
- **할 일**: 주(week) 단위 동적 DID 추정 + 계수 플롯
- **데이터 활용**:
  - 기존 논문: 사전 1개월(4주) + 사후 1개월(4주) = 8주
  - **확장 가능**: riders_full.csv에 2019-04부터 데이터 존재 → 사전 기간을 최대 18개월까지 확장 가능
  - 전략: 먼저 논문과 동일한 1개월 전후로 실행, 이후 확장 기간으로 재실행
- **수식**: `Y_it = α_i + γ_t + Σ β_k(Treat_i × 1[t=k]) + X'δ + ε_it`
- **산출물**:
  - Event-study 플롯 (Figure, PNG/PDF)
  - 사전 추세 계수 표
  - 결합 F-검정 결과
- **판단 기준**: 사전 계수 ≈ 0이면 GO, 유의한 추세 있으면 STOP & 전략 재수립
- **실행 가능 여부**: ✅ Python linearmodels 또는 R lfe로 구현
- **예상 소요**: 3-5일

### 1-2. Oster (2019) Bounds
- **할 일**: 비관측 선택 편의 민감도 분석
- **구현**: 통제변수 없는 회귀 → 전체 통제 회귀 → δ* 산출
- **산출물**: δ* 값 (표로 정리)
- **실행 가능 여부**: ✅ 수식 직접 구현 또는 R sensemakr 패키지
- **예상 소요**: 1-2일

### 1-3. 처리 강도 / 용량-반응
- **할 일**:
  - `AIShare_i` = (is_rec_assigned=1인 주문 수) / (사후 기간 전체 주문 수) 산출
  - 사분위별 처리 효과 추정 + 연속형 명세
- **산출물**: 용량-반응 표 + 그림
- **실행 가능 여부**: ✅ is_rec_assigned 변수가 데이터에 있음
- **예상 소요**: 2-3일

### 1-4. 안정 근로자 하위표본
- **할 일**: 도입 전후 근무 패턴 안정적인 라이더로 제한 후 재추정
- **산출물**: 하위표본 결과표
- **실행 가능 여부**: ✅ 일 단위 집계 데이터에서 산출 가능
- **예상 소요**: 1-2일

### 1-5. Gini/Theil 불평등 분해
- **할 일**: 생산성 분포의 불평등 지표 산출 (도입 전/후, 채택/비채택)
- **산출물**: 불평등 지표 표 + 분포 그림
- **실행 가능 여부**: ✅ numpy/scipy로 직접 계산
- **예상 소요**: 1-2일

### 1-6. 기간 내 학습 역학
- **할 일**: 사후 기간 내 주차별 AI 효과 변화 추정
- **산출물**: 주차별 효과 표 (이미 논문에 부분적으로 있음, 확장)
- **실행 가능 여부**: ✅
- **예상 소요**: 1일

### Phase 1 병렬화 전략
```
Day 1-2: 데이터 전처리 (Phase 0)
Day 3-5: Event-study (1-1) ← 이것만 집중
Day 5:   GO/NO-GO 판단
Day 6-8: Oster(1-2) + 용량-반응(1-3) + 안정근로자(1-4) ← 병렬
Day 9-10: Gini(1-5) + 학습역학(1-6) ← 병렬
```
**총 예상: 10일 (2주 내)**

---

## Phase 2: 문헌 리서치 (Phase 1과 병렬, 1주)

### 2-1. 핵심 논문 팩트체크 (deep-research 스킬)
- **할 일**: docs/05에서 인용한 핵심 주장 검증
  - [ ] Brynjolfsson et al. (2025): 저숙련 +30% 맞는지
  - [ ] Noy & Zhang (2023): 불평등 감소 맞는지
  - [ ] Dell'Acqua et al. (2023): 평균이하 +43% 맞는지
  - [ ] Knight et al. (2024): "productivity level" 용어 사용 맞는지
  - [ ] Chen et al. (2024): "AI" 용어 미사용 맞는지
  - [ ] Mao et al. (2025): "dispatch algorithms" 용어 맞는지
- **방법**: WebSearch + WebFetch로 오픈액세스 버전 접근, 초록/본문 확인
- **실행 가능 여부**: ✅ 대부분 오픈액세스 (NBER, SSRN, Science)
- **예상 소요**: 2-3일

### 2-2. 플랫폼 특화 신규 인용 탐색
- **할 일**: 긱 이코노미, 음식 배달, 라이드헤일링 실증 연구 15-20개 탐색
- **검색 키워드**:
  - "algorithmic management gig economy empirical"
  - "food delivery platform worker productivity"
  - "ride-hailing algorithmic assignment causal"
  - "platform work AI inequality"
- **방법**: Google Scholar + SSRN + WebSearch
- **산출물**: 주석 달린 참고문헌 목록 (docs/11-new-references.md)
- **실행 가능 여부**: ✅ 초록과 핵심 발견 확인 가능
- **예상 소요**: 2-3일

### 2-3. AI vs 알고리즘 디스패치 이론적 근거 보강
- **할 일**:
  - Russell & Norvig (2021) AI 정의 확인
  - Raisch & Krakowski (2021) automation-augmentation 구분 확인
  - 과업 기반 프레임워크 (Autor et al., 2003) 정확한 인용 확인
- **실행 가능 여부**: ✅ 교과서/고전 논문은 요약 접근 가능
- **예상 소요**: 1-2일

---

## Phase 3: 논문 재작성 (2-3주)

### 3-1. 서론 재구성 (academic-paper 스킬)
- **할 일**:
  - 의문형 도입 → 연구 맥락 → 공백 → 3개 RQ → 기여 → 경계 조건
  - 근로자/고객 병렬 제시
  - AI vs 알고리즘 초반 구분
- **산출물**: `manuscript/sections/01-introduction.md`
- **예상 소요**: 2-3일

### 3-2. 이론적 배경 재작성
- **할 일**:
  - 과업 기반 프레임워크 도입
  - 비판적 문헌 종합 (논쟁 중심)
  - 플랫폼 특화 문헌 통합
  - 공식 가설 번호 부여
- **산출물**: `manuscript/sections/02-theory.md`
- **예상 소요**: 3-4일

### 3-3. 제도적 배경 & 데이터 수정
- **할 일**:
  - AI 기술 구조 하위 섹션 (3.1.1) 추가
  - "proficiency" 용어 전환 + 정의
  - 대표성 논의 추가
- **산출물**: `manuscript/sections/03-context-data.md`
- **예상 소요**: 2-3일

### 3-4. 실증 전략 수정
- **할 일**:
  - 정확한 회귀 방정식 명시
  - 식별 가정/위협 확장
  - 소비자 측 FE 명세 명확화
- **산출물**: `manuscript/sections/04-empirical-strategy.md`
- **예상 소요**: 1-2일

### 3-5. 결과 섹션 수정
- **할 일**:
  - 용어 전환 (skill → proficiency)
  - 과업 기반 해석 추가
  - 소비자 주장 범위 축소
  - 신규 분석 결과 통합
- **산출물**: `manuscript/sections/05-results.md`
- **예상 소요**: 2-3일

### 3-6. 강건성 섹션 확장
- **할 일**: Phase 1 분석 결과 전부 통합
  - Event-study 그림 + 해석
  - Oster bounds 표 + 해석
  - 용량-반응 표/그림 + 해석
  - 안정 근로자 결과
  - Gini/Theil 결과
- **산출물**: `manuscript/sections/06-robustness.md`
- **예상 소요**: 2-3일

### 3-7. 토론 수정
- **할 일**:
  - 단기 증거 한정 표현
  - 사회적 영향 재프레이밍
  - 이론적/실무적 시사점
- **산출물**: `manuscript/sections/07-discussion.md`
- **예상 소요**: 2일

### 3-8. 결론 신규 작성
- **할 일**: 핵심 시사점 + 한계점 + 향후 연구
- **산출물**: `manuscript/sections/08-conclusion.md`
- **예상 소요**: 1-2일

### 3-9. 초록 수정
- **할 일**: 전체 수정 반영한 초록 재작성
- **산출물**: `manuscript/sections/00-abstract.md`
- **예상 소요**: 0.5일

---

## Phase 4: Response Letter 작성 (1주)

### 4-1. AE 대응 (가장 중요, 가장 길게)
- 3개 지적 각각에 1-2페이지
- 신규 텍스트 인용 + 표/그림 참조

### 4-2. R1 대응
- Major 4개 + Minor 3개 각각 대응
- 신규 분석 결과 직접 제시

### 4-3. R2 대응
- 11개 지적 각각 간결하게 대응
- 변경 섹션/페이지 참조

### 산출물: `manuscript/response-letter.md`
### 예상 소요: 3-5일

---

## Phase 5: 통합 & 마무리 (3-5일)

### 5-1. 전체 원고 통합
- 각 섹션 MD 파일 → 하나의 완성 원고로 통합
- 표/그림 번호 정리
- 참고문헌 통합 및 중복 제거
- 교차 참조 확인

### 5-2. 자체 리뷰
- academic-paper-reviewer 스킬의 **re-review 모드** 사용
- 리뷰어 지적사항 대비 수정 충분성 검증
- 누락된 대응 있는지 체크

### 5-3. DOCX 변환 (수동 작업 필요)
- Markdown → DOCX 변환 (pandoc)
- **저자가 최종 포맷팅, 표/그림 삽입, 저널 템플릿 적용해야 함**

### 산출물:
- `manuscript/full-revised-manuscript.md` (통합 원고)
- `manuscript/response-letter.md` (Response letter)
- `output/figures/` (모든 그림)
- `output/tables/` (모든 표)

---

## 전체 타임라인

```
Week 1:  Phase 0 (전처리) + Phase 1 시작 (Event-study)
Week 2:  Phase 1 나머지 분석 + Phase 2 (문헌 리서치) ← 병렬
Week 3:  Phase 3 시작 (서론, 이론, 배경)
Week 4:  Phase 3 계속 (결과, 강건성, 토론)
Week 5:  Phase 3 완료 (결론, 초록) + Phase 4 (Response letter)
Week 6:  Phase 5 (통합, 자체 리뷰, 마무리)
```

**목표: 6주 내 완료 → 5월 중순 제출 (마감 5/30 대비 2주 여유)**

---

## 실행 방식

### ralph + academic 스킬 활용 전략

| Phase | 실행 도구 | 이유 |
|-------|----------|------|
| Phase 0-1 (데이터/분석) | **ralph** | 반복 검증 필요, 코드 실행 + 결과 확인 루프 |
| Phase 2 (문헌) | **deep-research 스킬** | 체계적 문헌 검색 + 교차 검증에 최적화 |
| Phase 3 (논문 작성) | **academic-paper 스킬** (revision mode) | 학술 논문 작성에 특화된 12-에이전트 파이프라인 |
| Phase 4 (Response letter) | **academic-paper 스킬** (parse reviews mode) | 리뷰 파싱 + 수정 로드맵 기능 |
| Phase 5 (자체 리뷰) | **academic-paper-reviewer 스킬** (re-review mode) | 수정이 리뷰 코멘트를 충분히 대응했는지 검증 |

### 레포 관리
- 모든 작업은 `ijim_ai_research` 레포에서 진행
- Phase별로 커밋 & push
- 브랜치 전략: `main`에서 직접 (단일 저자 작업)

---

## 리스크 & 대응

| 리스크 | 확률 | 대응 |
|--------|------|------|
| Event-study pre-trend 실패 | 15-25% | 대안 식별 전략 검토 (synthetic control, bounds) |
| 데이터 전처리 오류 | 10% | 기존 R 코드 결과와 교차 검증 |
| 문헌 팩트체크에서 주요 주장 오류 발견 | 10% | 해당 주장 수정/삭제, 대안 근거 탐색 |
| 분량이 저널 제한 초과 | 20% | 핵심만 본문, 나머지 온라인 부록 |
| 5월 30일 마감 촉박 | 15% | Phase 3 병렬화 강화, 필수 아닌 분석 후순위로 |

---

## 다음 단계

Phase 0부터 바로 시작하려면:
1. 기존 R 코드의 전처리 파이프라인을 Python으로 구축
2. riders_full.csv에서 부산 지역 + 분석 기간 추출
3. 핵심 변수 생성 (스택, 일 단위 집계)
4. 기존 결과 재현 검증
5. Event-study 실행

**시작할까요?**
