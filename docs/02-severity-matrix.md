# 심각도 x 실현가능성 매트릭스

## 범례
- **심각도**: CRITICAL (수락 차단) / HIGH (강하게 기대됨) / MEDIUM (논문 개선) / LOW (있으면 좋음)
- **실현가능성**: Easy (재작성) / Moderate (기존 데이터 추가 분석) / Hard (대규모 재구조화) / Impossible
- **전략**: REFRAME (재프레이밍) / REWRITE (재작성) / NEW ANALYSIS (신규 분석) / ACKNOWLEDGE (인정)

---

## AE (부편집장) 지적사항

| ID | 지적 내용 | 심각도 | 실현가능성 | 전략 |
|----|----------|--------|-----------|------|
| AE-1 | "Labour skill" 용어 오해 유발 | **CRITICAL** | Easy | REWRITE: 전체 "proficiency level"로 변경 |
| AE-2 | 연구 목적 불명확; 근로자-고객 상호관계 미조사 | **CRITICAL** | Moderate | REFRAME + NEW ANALYSIS: RQ 재구성, 매개 분석 추가 |
| AE-3 | AI 구현 상세 없이 사회적 영향 주장 투기적 | **CRITICAL** | Moderate-Hard | REWRITE + NEW CONTENT: AI 기술 설명 추가, 주장 축소 |

## 리뷰어 1 지적사항

| ID | 지적 내용 | 심각도 | 실현가능성 | 전략 |
|----|----------|--------|-----------|------|
| R1-1 | 기여도 포지셔닝 불분명 | **HIGH** | Easy | REFRAME: "이질적 효과 + task-based 메커니즘" 강조 |
| R1-2 | AI vs 기존 알고리즘 디스패치 구분 필요 | **CRITICAL** | Moderate | REWRITE: 기술 하위 섹션 추가 |
| R1-3A | Event-study / 동적 DID 필요 | **CRITICAL** | Moderate | NEW ANALYSIS: 기간별 처리 효과 |
| R1-3B | 처리 강도 측정 | **HIGH** | Moderate | NEW ANALYSIS: AI 사용 비율, 용량-반응 |
| R1-3C | 시변 선택 편의 강건성 | **HIGH** | Moderate | NEW ANALYSIS: Oster bounds, 대안 매칭 |
| R1-4 | 소비자 후생 주장 과대 | **HIGH** | Easy-Moderate | REFRAME: 조건부 표현 사용 |
| R1-M1 | 참고문헌 중복 (Chen 2024a/b) | **LOW** | Easy | REWRITE: 중복 제거 |
| R1-M2 | 불평등 지표 (Gini/Theil) | **MEDIUM** | Moderate | NEW ANALYSIS: 공식 분해 |
| R1-M3 | 소비자 고정효과 명세 | **MEDIUM** | Easy | REWRITE: 주석 추가 |

## 리뷰어 2 지적사항

| ID | 지적 내용 | 심각도 | 실현가능성 | 전략 |
|----|----------|--------|-----------|------|
| R2-1 | 서론에서 증거 전에 AI "가치 창출" 단언 | **MEDIUM** | Easy | REWRITE: 의문형 프레이밍 |
| R2-2 | 서론에서 근로자만 강조, 고객 논의 지연 | **HIGH** | Easy | REWRITE: 다중 이해관계자 선두 배치 |
| R2-3 | 서론에 한계점 논의 부재 | **MEDIUM** | Easy | REWRITE: 경계 조건 문단 추가 |
| R2-4 | 문헌 리뷰 비판적이지 않음 | **HIGH** | Easy-Moderate | REWRITE: 논쟁 중심 재구성 |
| R2-5 | 플랫폼 특화 연구 대신 일반 연구 인용 | **HIGH** | Easy-Moderate | NEW CONTENT: 인용 15-20개 추가 |
| R2-6 | 데이터 1개월; 대표성 논의 부재 | **HIGH** | Moderate-Hard | ACKNOWLEDGE + NEW ANALYSIS |
| R2-7 | 자기 선택 편의 + 짧은 기간 | **CRITICAL** | Moderate | NEW ANALYSIS: R1-3과 중복 |
| R2-8 | 단기 결과 과잉 해석 | **HIGH** | Easy | REWRITE: "단기 증거에 따르면..." |
| R2-9 | 학습 곡선 주장에 실증 근거 없음 | **MEDIUM** | Moderate | NEW ANALYSIS: 기간 내 역학 |
| R2-10 | 단일 과업/플랫폼/국가 | **MEDIUM** | Easy | ACKNOWLEDGE: 한계점 소섹션 |
| R2-11 | 결론/시사점/한계점 섹션 없음 | **CRITICAL** | Easy | REWRITE: 전부 추가 |
