# "Skill" → "Proficiency" 용어 전환 전략

## AE 원문
> "I have serious reservations regarding the study's theoretical setting, particularly the definition of 'labour skill.' Categorizing workers based solely on their performance prior to AI introduction is potentially misleading. A more accurate classification would be 'high,' 'medium,' and 'low' performance."

---

## AE가 맞는가?

**부분적으로 맞고, 중요한 지적이다.**

- **성과(Performance)** = 관찰된 결과 (시간당 주문 수). 직접 측정 가능
- **숙련도(Skill)** = 잠재적 기저 능력. 직접 관측 불가, 추론해야 함

논문은 도입 전 일일 생산성을 측정하면서 "skill"이라 부름. 주장과 측정 사이에 괴리가 발생:
- 높은 기저 능력이나 비피크 시간 근무 → "low-skilled"로 분류될 수 있음
- 보통 능력이나 피크 시간 전문 근무 → "high-skilled"로 분류될 수 있음
- 도입 전 성과는 숙련도 외에 노력, 수요 조건, 경로 친숙도, 전략적 선택이 혼재

---

## 비교 가능 논문들의 처리 방식

| 논문 | 측정 지표 | 사용 용어 |
|------|----------|----------|
| Brynjolfsson et al. (2025, QJE) | 사전 기간 처리건/시간 | "worker ability" / "생산성 분위" |
| Noy & Zhang (2023, Science) | 사전 처리 품질 점수 | "중위 이하/이상" 수행자 |
| Dell'Acqua et al. (2023, HBS) | 사전 실험 성과 | "performance level" |
| Knight et al. (2024, EC) | 사전 기간 피킹 속도 | **"productivity level"** |

**패턴**: 최상위 저널은 무조건적 "skill" 사용을 회피. "ability", "productivity level", 또는 분포 내 위치 기술을 사용.

---

## 3가지 옵션 평가

### 옵션 A: "Performance Level"로 전체 교체
- **장점**: AE 제안을 직접 수용; 정직; 빠름
- **단점**: 이론적 서사 약화; "중간 성과 근로자의 성과가 개선됨" = 동어반복적
- **AE 만족 확률**: 80-90%

### 옵션 B: "Skill" 유지 + 이론적 정당화 강화
- **장점**: 이론적 기여와 서사 보존
- **단점**: 위험 — AE가 이미 "misleading"이라 판단; 비반응적으로 인식될 수 있음
- **AE 만족 확률**: 30-50%

### 옵션 C: "Proficiency Level" + 이론적 근거 (권장)
- **장점**: 중간 지대 — 축적된 역량 암시(성과보다 깊음), 선천적 능력 과잉 주장 회피; 학습 곡선과 자연스럽게 연결; 논문에 이미 "proficiency" 3회 사용
- **단점**: 약간의 이론적 개발 필요
- **AE 만족 확률**: 75-85%

---

## 권장 접근: 옵션 C

### 전체 교체표

| 현재 | 교체 |
|------|------|
| low-skilled riders | low-proficiency riders |
| medium-skilled riders | medium-proficiency riders |
| high-skilled riders | high-proficiency riders |
| skill levels | proficiency levels |
| skill disparities | proficiency-based productivity disparities (첫 사용), 이후 "productivity disparities" |
| rider skill level | rider proficiency level |

### Section 3 (데이터): 새 분류 문단

> "숙련 수준별 이질적 효과를 고려하기 위해, 라이더를 도입 전 배송 숙련도(delivery proficiency)에 따라 분류한다. 음식 배달에서 숙련도는 라이더의 생산성을 공동으로 결정하는 과업 관련 역량의 복합체를 포괄한다: 주문 평가 및 선택 능력, 경로 계획 및 탐색 효율성, 주문 스태킹 및 순서 최적화, 배송 간 시간 관리. 이러한 구성 역량은 데이터에서 개별적으로 관측할 수 없으므로, 도입 전 기간 각 라이더의 평균 일일 생산성(근무 시간당 주문 수)을 전체 배송 숙련도의 집계 대리변수로 사용한다. 이 접근은 AI-노동 문헌에서 도입 전 산출물로 근로자를 계층화하는 관례를 따른다(Brynjolfsson et al., 2025; Knight et al., 2024; Noy & Zhang, 2023).
>
> 라이더를 도입 전 일일 생산성에 따라 균등 3분위로 나눈다: 저숙련(low-proficiency), 중숙련(medium-proficiency), 고숙련(high-proficiency) (각각 생산성 분포의 하위, 중간, 상위 1/3). 분류가 관측 기간 중 입증된 과업 역량을 포착하되, 기저 배송 능력과 밀접하게 관련되면서도 노력 배분이나 수요 조건 같은 요인을 반영할 수도 있음을 나타내기 위해 'skill' 대신 'proficiency'를 사용한다."

### 뒷받침 근거 문단

> "세 숙련 그룹은 생산성뿐 아니라 기저 역량 차이와 일관된 행동 패턴에서도 다르다. Table 2에서 보듯이, 고숙련 라이더는 스택당 더 많은 주문을 완료하고(4.69 vs 저숙련 2.19), 주문당 평균 처리 시간이 더 짧으며(9.77 vs 14.03분), 스택 간 유휴 시간도 더 짧다(7.42 vs 11.37분). 이러한 여러 운영 차원에서의 체계적 차이는 도입 전 생산성이 일시적 성과 변동이 아닌 지속적 역량 차이를 포착함을 시사한다."

### Section 2 (이론): Task-based 프레임워크 추가

> "과업 기반 프레임워크(Autor et al., 2003; Acemoglu & Autor, 2011)에 근거하여 이질적 AI 효과를 분석한다. 음식 배달에서 라이더의 작업 흐름은 구별되는 과업 구성요소로 이루어진다: (1) 주문 평가 및 선택, (2) 주문 수락 및 스태킹 결정, (3) 픽업 순서 및 경로 설정, (4) 물리적 탐색 및 운전, (5) 고객 인도. 주문 배정 AI는 구성요소 (1)을 직접 자동화하지만, 구성요소 (2)-(5)는 라이더의 판단과 실행에 맡겨진다.
>
> 이 관점에서 핵심적 통찰은 알고리즘 과업 배정이 자동화하는 구성요소만 개선할 수 있다는 것이다. 이미 주문 선택에 탁월한 라이더(고숙련)는 이득이 적다. 하류 실행에 어려움을 겪는 라이더(저숙련)는 더 잘 매칭된 주문을 받더라도 순서 및 경로 관리의 결함으로 완전히 활용하지 못한다. 중숙련 라이더 — 적절한 실행 역량을 갖추었으나 차선의 주문 선택 판단력을 가진 — 가 가장 큰 이득을 얻는데, AI가 그들의 구속 제약(binding constraint)을 해소하기 때문이다."

### Response Letter 표현

> "부편집장의 이 중요한 지적에 감사드립니다. 도입 전 생산성 기반 분류를 '숙련도(skill)'로 기술한 원래의 표현이 부정확하고 오해를 유발할 수 있었다는 점에 전적으로 동의합니다. 수정 원고에서 라이더를 '배송 숙련 수준(delivery proficiency level)'으로 분류하고, 과업 기반 이론적 프레임워크(Autor et al., 2003; Acemoglu & Autor, 2011)에 근거한 명시적 정의를 제공합니다. 우리의 이론적 논증 — AI 혜택이 자동화된 과업과 비자동화된 과업 구성요소 간의 상호작용에 달려 있다는 — 이 단순한 관측 산출이 아닌 축적된 과업 역량을 포착하는 개념을 필요로 하기에 '성과(performance)' 대신 '숙련도(proficiency)'를 선택했습니다."

---

## 필요한 검증 작업
- [ ] 도입 전 기간 내 순위 안정성 보고 (1-2주차와 3-4주차 간 Spearman 상관)
- [ ] 라이더 재직 기간 데이터 존재 시: 재직 기간과 도입 전 생산성 상관 분석
- [ ] 4분위/5분위 분할 또는 연속형 상호작용에 대한 강건성 검정
- [ ] 3분위 경계값(시간당 주문 수) 명시적 보고
