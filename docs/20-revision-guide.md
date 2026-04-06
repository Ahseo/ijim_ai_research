# IJIM 논문 수정 지침서: 지적별 상세 수정 가이드

> **사용법**: 각 지적사항에 대해 **무엇을**, **어디를**, **근거**, **참고 텍스트**(영어 초안)를 제공합니다.
> 참고 텍스트는 저자가 직접 원고에 삽입/수정할 수 있도록 영어로 작성되었습니다.
> 모든 분석 참조는 `output/` 폴더의 실제 파일 경로와 매칭됩니다.

---

# Part 1. 수렴 이슈 (C1--C9)

2명 이상의 평가자가 공통으로 지적한 핵심 사항. 하나라도 미해결 시 reject 가능성 높음.

---

## C1. "Skill" 용어가 오해를 유발

- **지적자**: AE (명시적), R1 (암묵적)
- **심각도**: CRITICAL

### 무엇을
논문 전체에서 "skill level"을 "proficiency level"로 교체하고, 도입 전 생산성 기반 분류의 이론적 근거를 과업 기반 프레임워크(task-based framework)로 보강한다.

### 어디를
- **초록**: "skilled" 관련 모든 표현
- **Section 1 (서론)**: "skill" 관련 표현 전체
- **Section 2 (이론)**: 과업 기반 프레임워크 하위 섹션 신설 (Section 2.3)
- **Section 3 (데이터)**: 분류 방법론 문단 재작성
- **Table 1, 2, 4, 5, 6**: 열 라벨/행 라벨 교체
- **모든 본문, 그림, 부록**: "low/medium/high-skilled" → "low/medium/high-proficiency"

### 근거
- `docs/06-terminology-reframing.md` (전환 전략 상세)
- Brynjolfsson et al. (2025): "worker ability" 사용
- Noy & Zhang (2023): "below/above median" 사용
- Dell'Acqua et al. (2023): "performance level" 사용
- Knight et al. (2024, ISR): "skill level" 사용 -- 팩트체크 결과(`docs/11-fact-check.md` #4) ISR 저널판 제목에 "Skill Level" 명시, 따라서 "skill 미사용" 근거로 인용 불가
- Autor et al. (2003), Acemoglu & Autor (2011): 과업 기반 프레임워크 원전

### 참고 텍스트

**Section 3 (데이터) -- 분류 문단 교체:**

> To examine heterogeneous effects by proficiency level, we classify riders according to their pre-adoption delivery proficiency. In food delivery, proficiency encompasses a composite of task-related competencies that jointly determine a rider's productivity: order evaluation and selection ability, route planning and navigation efficiency, order stacking and sequencing optimization, and inter-delivery time management. Because these constituent competencies are not individually observable in our data, we use each rider's mean daily productivity (orders per working hour) during the pre-adoption period as an aggregate proxy for overall delivery proficiency. This approach follows the established convention in the AI-labor literature of stratifying workers by pre-treatment output (Brynjolfsson et al., 2025; Knight et al., 2024; Noy & Zhang, 2023).
>
> We partition riders into equal terciles based on pre-adoption daily productivity: low-proficiency, medium-proficiency, and high-proficiency (corresponding to the bottom, middle, and top thirds of the productivity distribution, respectively). We use "proficiency" rather than "skill" to signal that the classification captures demonstrated task competence during the observation period -- closely related to, but not identical with, underlying delivery ability -- and may also reflect factors such as effort allocation and demand conditions.

**Section 2 (이론) -- 과업 기반 프레임워크 하위 섹션:**

> Drawing on the task-based framework (Autor et al., 2003; Acemoglu & Autor, 2011), we analyze heterogeneous AI effects through the lens of task composition. In food delivery, a rider's workflow comprises distinguishable task components: (1) order evaluation and selection, (2) order acceptance and stacking decisions, (3) pickup sequencing and route planning, (4) physical navigation and driving, and (5) customer handoff. The order-assignment AI directly automates component (1) but leaves components (2) through (5) to the rider's judgment and execution.
>
> The key insight from this perspective is that algorithmic task assignment can only improve the component it automates. Riders who already excel at order selection (high-proficiency) gain little. Riders who struggle with downstream execution (low-proficiency) cannot fully capitalize on better-matched orders because deficiencies in sequencing and route management remain binding. Medium-proficiency riders -- possessing adequate execution competence but suboptimal order-selection judgment -- stand to gain the most, as AI resolves their binding constraint.

**용어 교체표:**

| 현재 표현 | 교체 표현 |
|----------|----------|
| low-skilled riders | low-proficiency riders |
| medium-skilled riders | medium-proficiency riders |
| high-skilled riders | high-proficiency riders |
| skill levels | proficiency levels |
| skill disparities | proficiency-based productivity disparities |
| rider skill level | rider proficiency level |

---

## C2. 자기 선택 / 내생성 문제 미해결

- **지적자**: R1 (Major #3), R2 (#7), AE ("structural")
- **심각도**: CRITICAL

### 무엇을
4가지 보완 분석(event-study, Oster bounds, 용량-반응, 안정 근로자)을 추가하고, 식별 전략 섹션을 대폭 확장한다. PSM+DID가 내생성을 "해결한다"고 주장하지 않고, 증거의 수렴(convergence of evidence)으로 프레이밍한다.

### 어디를
- **Section 4 (실증 전략)**: Section 4.3 "식별 가정과 위협" 확장
- **Section 6 (강건성)**: 신규 하위 섹션 6.1--6.4 추가
- **Section 8 (결론)**: 한계점에 잔여 내생성 명시

### 근거
- **Event-study**: `output/interpretation/01-event-study.md`, `output/tables/event_study_coefficients.csv`, `output/figures/event_study_productivity.png`
  - 결합 F-검정 = 1.408, p = 0.229 → 병행 추세 가정 지지
- **Oster bounds**: `output/interpretation/02-oster-bounds.md`, `output/tables/oster_bounds.csv`
  - delta* = -1.249, |delta*| > 1 → 강건
- **용량-반응**: `output/interpretation/03-dose-response.md`, `output/tables/dose_response_quartiles.csv`, `output/figures/dose_response.png`
  - 연속형 beta = -0.360; 사분위별 비단조 패턴
- **안정 근로자**: `output/interpretation/04-stable-workers.md`, `output/tables/stable_workers.csv`
  - 안정 근로자 691/790명(87.5%), beta = 0.003 (전체 95% CI 내)
- 방법론 참고: Sun & Abraham (2021), Oster (2019), Callaway & Sant'Anna (2021)
- `docs/07-identification-strategy.md` (전략 상세)

### 참고 텍스트

**Section 4.3 -- 식별 가정과 위협:**

> We acknowledge that voluntary AI adoption creates identification challenges that PSM-DID alone cannot fully resolve. While PSM addresses observable selection and DID eliminates time-invariant unobservables, time-varying unobservable selection -- wherein adopters may have been on differential trajectories irrespective of AI -- remains a potential threat. We address this concern through four complementary analyses.

**Section 6.1 -- Event-Study:**

> To provide direct evidence on the parallel trends assumption, we estimate a dynamic DID specification with weekly event-time indicators (Sun & Abraham, 2021). Figure [X] plots the event-study coefficients with 95% confidence intervals. All pre-treatment coefficients are individually insignificant, and a joint F-test yields F = 1.408 (p = 0.229), supporting the parallel trends assumption. The absence of differential pre-trends strengthens the causal interpretation of our DID estimates.

**Section 6.2 -- Oster Bounds:**

> Following Oster (2019), we assess the sensitivity of our estimates to unobservable selection. The bias-adjusted coefficient yields delta* = -1.249, indicating that unobservable selection would need to be at least 1.25 times as important as all observed covariates combined to fully explain away the estimated treatment effect. As |delta*| > 1, our estimates satisfy Oster's recommended threshold for robustness to omitted variable bias.

**Section 6.3 -- 용량-반응:**

> We construct a continuous treatment intensity measure, AIShare_i, defined as the proportion of post-adoption orders assigned through the AI system for each rider. The continuous specification yields beta = -0.360 (SE = 0.203). Quartile-based analysis reveals a non-monotonic pattern across AI usage intensity (Q1: -0.228; Q2: -1.707; Q3: -0.178), providing suggestive evidence of a dose-response relationship. While the dose itself is endogenous, the pattern is difficult to reconcile with pure selection on unobservables, which would require the confound to scale precisely with usage intensity.

**Section 6.4 -- 안정 근로자:**

> To address the concern that AI adopters may have simultaneously changed their work behavior, we restrict the sample to "stable workers" -- riders whose average weekly working hours changed by less than one standard deviation between the pre- and post-adoption periods. This subsample retains 691 of 790 riders (87.5%). The treatment effect estimate for stable workers (beta = 0.003, SE = 0.066) falls within the 95% confidence interval of the full-sample estimate (beta = 0.127, SE = 0.159), confirming that results are not driven by concurrent behavioral changes among adopters.

**Section 8 (한계점):**

> Our identification strategy cannot definitively rule out all forms of time-varying unobservable selection. We present the convergence of four complementary analyses -- event-study validation of parallel trends, Oster bounds for unobservable selection, dose-response patterns, and stable-worker robustness -- as collectively narrowing the scope of plausible alternative explanations, while acknowledging that a randomized or instrumental-variable design would provide stronger causal evidence.

---

## C3. 소비자 측 주장 과대

- **지적자**: AE (#2), R1 (Major #4), R2 (#2)
- **심각도**: HIGH

### 무엇을
소비자 후생 주장의 범위를 축소한다. "플랫폼 전체 소비자 후생 개선"이 아니라 "처리군 라이더가 서비스한 고객의 조건부 경험"으로 표현을 한정한다.

### 어디를
- **초록**: 소비자 관련 문장
- **Section 1 (서론)**: RQ3 표현
- **Section 5.3 (고객 경험 결과)**: 결과 해석 문단
- **Section 7 (토론)**: 시사점 문단
- **Table 7 제목/주석**

### 근거
- `output/tables/table7_waiting_time.csv`: 대기시간 효과 = 0.019 (SE = 0.165, p = 0.909) -- 통계적으로 비유의
- `docs/09-paper-architecture.md` (Section 5.3 설계)

### 참고 텍스트

**초록 수정:**

> Regarding customer experience, we find no statistically significant reduction in delivery waiting times for customers served by AI-adopting riders (beta = 0.019, p = 0.909), suggesting that worker-side efficiency gains do not automatically translate into measurable improvements in the customer delivery experience within our observation window.

**Section 5.3 -- 결과 해석:**

> Table 7 reports the effect of AI adoption on customer waiting times. The estimated coefficient is substantively small and statistically insignificant across all specifications (all-orders: beta = 0.019, SE = 0.165, p = 0.909; single-order: beta = 0.005, SE = 0.147, p = 0.974; stacked-order: beta = 0.005, SE = 0.174, p = 0.978). We interpret these null results cautiously: they pertain only to customers served by treated riders and do not capture potential platform-wide equilibrium effects. The absence of a detectable customer-side effect may reflect the short observation window, strategic rider behavior (e.g., accepting more stacked orders that offset per-customer time savings), or the possibility that efficiency gains are absorbed by riders as increased earnings rather than passed through as faster delivery.

**Section 7 -- 시사점 수정:**

> We emphasize that our customer-side estimates are conditional on being served by an AI-adopting rider and cannot be extrapolated to platform-wide consumer welfare. Estimating general equilibrium effects on the full consumer population would require platform-level data encompassing all riders and customers, which lies beyond the scope of this study.

---

## C4. "AI"가 무엇인지 불명확

- **지적자**: AE (#3), R1 (Major #2)
- **심각도**: CRITICAL

### 무엇을
AI 시스템의 기술 구조를 명시하는 하위 섹션(Section 3.1.1)을 신설한다. 기존 규칙 기반/최적화 기반 디스패치와 본 시스템의 ML 기반 AI를 3가지 특성으로 구분한다.

### 어디를
- **Section 3.1**: 신규 하위 섹션 "3.1.1 Technical Architecture of the AI Order-Assignment System" 추가
- **Section 2.1**: AI vs 알고리즘 디스패치 구분 논의 추가
- **Table (신규)**: 기술 분류 비교표

### 근거
- `docs/05-ai-vs-dispatch.md` (기술 분류 체계 및 비교표)
- Russell & Norvig (2021): AI 표준 정의
- Raisch & Krakowski (2021): AI vs 자동화 구분
- Berente et al. (2021): IS 분야 AI 조작적 정의
- Chen et al. (2024): "algorithmic assignment" (AI 미사용) -- 대비 사례
- Mao et al. (2025): "dispatch algorithms" (AI 미사용) -- 대비 사례

### 참고 텍스트

**Section 3.1.1 -- AI 시스템 기술 구조:**

> The order-assignment system introduced by the platform qualifies as AI-based in that it incorporates machine-learning components that distinguish it from conventional automated dispatch or rule-based optimization. Three properties locate this system in the domain of AI rather than algorithmic optimization.
>
> First, the system performs *revealed preference estimation*: using each rider's historical delivery records, it estimates a probabilistic distribution of order preferences conditional on logistics context. This is a supervised learning task that infers latent rider preferences from observed delivery choices, rather than following hand-coded assignment rules.
>
> Second, the system generates a *personalized matching-quality score* for each rider-order pair, incorporating the rider's specific behavioral history, current status, and inferred preferences. This personalization goes beyond conventional optimization-based dispatch, which minimizes a system-level objective function without modeling individual-level preference heterogeneity.
>
> Third, the system *dynamically updates* its preference model as new delivery records accumulate, enabling adaptation to changes in rider behavior over time. This distinguishes it from static optimization with fixed parameters.
>
> These three properties -- learning from data, personalization via preference estimation, and dynamic updating -- constitute the AI components of this system and align with established definitions of AI (Russell & Norvig, 2021; Raisch & Krakowski, 2021). Table [X] contrasts this system with rule-based dispatch and optimization-based algorithms studied in prior platform research (Chen et al., 2024; Mao et al., 2025).

**비교표 (Table [X]):**

> | Feature | Rule-Based Dispatch | Optimization-Based Algorithms | ML-Based AI Assignment (This Study) |
> |---------|-------------------|-------------------------------|--------------------------------------|
> | Decision logic | Deterministic rules (e.g., nearest available) | Mathematical programming / heuristics | Supervised learning from historical data |
> | Personalization | None | None (system-level objective) | Individual rider preference modeling |
> | Learning | None | None | Continuous model updating |
> | Adaptiveness | Static | Static parameters | Dynamic adaptation to behavioral change |
> | Examples in literature | Early ride-hailing platforms | Mao et al. (2025); Chen et al. (2024) | Knight et al. (2024); This study |

---

## C5. 사회적 평등 주장이 투기적

- **지적자**: AE (#3), R2 (#8)
- **심각도**: HIGH

### 무엇을
"사회적 평등(social equality)" 표현을 "진보적 분배 결과(progressive distributional outcome)"로 축소하고, 천장 효과 메커니즘을 제시하며, 설계 의도 없이 평등화 효과를 낳은 선행 연구로 반론을 구성한다.

### 어디를
- **초록**: "social equality" 표현 삭제/교체
- **Section 1 (서론)**: 사회적 함의 문장 수정
- **Section 7.4 (사회적 영향 논의)**: 신규 프레이밍으로 재작성
- **Section 8 (결론)**: 한정적 표현 사용

### 근거
- `docs/05-ai-vs-dispatch.md` (반론 근거 섹션)
- `output/interpretation/05-inequality.md`, `output/tables/inequality_metrics.csv`: Gini 0.181 → 0.152 (감소)
- `output/tables/inequality_overall.csv`: Theil 지수 0.128 → 0.055 (감소)
- Brynjolfsson et al. (2025): 저숙련 +34%, 고숙련 ~0% (설계 의도 없이 격차 축소)
- Noy & Zhang (2023): "compresses the productivity distribution"
- Dell'Acqua et al. (2023): 평균이하 +43%, 이상 +17% (frontier 내 과제 한정)
- Merton (1936): 의도하지 않은 결과 이론

### 참고 텍스트

**Section 7.4 -- 사회적 영향 논의 (전체 교체):**

> We do not claim that the platform's AI was designed to promote social equality. Rather, we document an empirically notable finding that AI-driven task assignment partially attenuates productivity disparities across proficiency levels and offer a mechanism explanation grounded in the differential marginal returns of AI-assisted order selection by proficiency group. The Gini coefficient of hourly productivity declined from 0.181 to 0.152 following AI adoption, and the Theil index fell from 0.128 to 0.055, indicating a compression of the productivity distribution.
>
> This pattern is consistent with a growing body of evidence showing that AI tools can produce inequality-reducing effects without being designed for that purpose. Brynjolfsson et al. (2025) found that generative AI assistance improved low-ability customer service agents' productivity by 34% while leaving high-ability agents largely unaffected. Noy and Zhang (2023) documented that ChatGPT access "compresses the productivity distribution" among professional writers. Dell'Acqua et al. (2023) reported that below-average consultants gained 43% from GPT-4 assistance versus 17% for above-average consultants on tasks within AI's capability frontier.
>
> The theoretical mechanism is straightforward: a ceiling effect. High-proficiency riders already approach the performance frontier in order selection, leaving limited room for AI-driven improvement. Low-proficiency riders face binding constraints in downstream task execution (navigation, sequencing) that better order matching alone cannot resolve. Medium-proficiency riders -- possessing adequate execution skills but suboptimal selection judgment -- capture the largest gains because AI addresses precisely their binding constraint. This mechanism aligns with Merton's (1936) framework of unanticipated consequences: distributional outcomes depend on which tasks are automated, not on the designer's redistributive intent.
>
> We therefore characterize our findings as documenting a *progressive distributional pattern* -- a descriptive regularity warranting further investigation -- rather than evidence of structural equality promotion.

---

## C6. 관찰 기간 너무 짧음 (전후 각 1개월)

- **지적자**: R1 (암묵적), R2 (#6, #7, #8), AE ("insufficient data coverage")
- **심각도**: HIGH

### 무엇을
짧은 관찰 기간을 명시적으로 인정하되, (1) 제도적 정당화, (2) 기간 내 역학 분석, (3) 명시적 한계점 섹션으로 대응한다.

### 어디를
- **Section 3.2 (데이터)**: 기간 선택 정당화 문단 추가
- **Section 6.6 (기간 내 역학)**: 신규 하위 섹션
- **Section 8.2 (한계점)**: 시간적 범위 한계 첫 번째 항목

### 근거
- `output/interpretation/06-learning-dynamics.md`, `output/tables/learning_dynamics.csv`
  - Week 1: +0.079, Week 4: +0.284 (시간-효과 상관 0.477)
- `docs/07-identification-strategy.md` (해결 불가능한 한계 인정)

### 참고 텍스트

**Section 3.2 -- 기간 정당화:**

> Our observation window spans one month before and one month after AI introduction. This temporal scope reflects institutional constraints: the platform introduced the AI system as a discrete event, and our data access agreement covers this specific transition period. While we acknowledge that longer observation would strengthen causal inference and enable detection of learning effects and behavioral adaptation, we note that (a) the pre-adoption period is sufficient to establish stable baseline performance patterns, (b) prior studies of AI introduction have documented measurable effects within comparable timeframes (Brynjolfsson et al., 2025, report significant effects within two months), and (c) we conduct within-period dynamics analysis to assess whether effects are stabilizing, growing, or dissipating.

**Section 6.6 -- 기간 내 역학:**

> To assess whether AI effects exhibit temporal dynamics within our observation window, we estimate week-specific treatment effects for the four post-adoption weeks. The coefficients suggest a pattern of increasing effect magnitude over time (Week 1: beta = 0.079, p = 0.374; Week 2: beta = -0.028, p = 0.755; Week 3: beta = -0.065, p = 0.470; Week 4: beta = 0.284, p = 0.407), with a time-effect correlation of 0.477. While no individual weekly coefficient reaches statistical significance -- consistent with the reduced statistical power of week-level estimation -- the positive correlation between elapsed time and effect magnitude is suggestive of a learning process in which riders gradually learn to leverage AI-assigned orders more effectively. This pattern warrants investigation with longer observation periods.

**Section 8.2 -- 시간적 한계:**

> First, our observation window of one month before and after AI introduction limits our ability to distinguish transient novelty effects from permanent behavioral changes, to detect long-run learning dynamics, and to assess whether the progressive distributional pattern persists over time. Future research with longer panels is needed to establish the durability and evolution of AI-driven productivity effects.

---

## C7. 연구 목적 불명확

- **지적자**: AE (#2), R2 (#2, #3)
- **심각도**: CRITICAL

### 무엇을
서론을 3개의 한정된, 반증 가능한 연구 질문(RQ)으로 재구성한다. 근로자와 고객을 병렬로 제시하고, 경계 조건 문단을 추가한다.

### 어디를
- **Section 1 (서론)**: 전면 재구성 (1.1--1.6)
- **Section 2.5 (가설)**: 공식 번호 부여된 가설로 정리

### 근거
- `docs/09-paper-architecture.md` (서론 구조 설계 1.1--1.6, 가설 H1--H3b)
- AE 원문: "the gap in literature and the specific contribution of this research is not clearly defined"
- R2 #2: "only mentions workers initially... customer discussion comes much later"

### 참고 텍스트

**Section 1.4 -- 연구 질문:**

> This study addresses three research questions:
>
> **RQ1.** How does AI-driven task assignment affect worker productivity across baseline proficiency levels?
>
> **RQ2.** Does AI compress or widen the productivity distribution among platform workers?
>
> **RQ3.** Does AI improve the customer delivery experience, and if so, is the improvement mediated by worker-side efficiency gains?

**Section 1.6 -- 경계 조건 (신규):**

> Several boundary conditions delimit the scope of our claims. First, our estimates capture the average treatment effect on the treated (ATT) -- the effect on riders who voluntarily adopted AI -- which may differ from the average treatment effect (ATE) on the full rider population. Second, our data span a single platform in one country over a two-month window, limiting generalizability across platforms, geographies, and time horizons. Third, our customer-side estimates are conditional on being served by an AI-adopting rider and do not capture platform-wide equilibrium effects on consumer welfare. We return to these limitations in Section 8.

**Section 2.5 -- 가설:**

> Based on the theoretical framework developed above, we formulate the following hypotheses:
>
> **H1.** AI-driven task assignment improves average worker productivity.
>
> **H2.** Productivity gains are largest for medium-proficiency riders, moderate for low-proficiency riders, and smallest for high-proficiency riders.
>
> **H3a.** AI adoption reduces customer waiting times for single-order deliveries.
>
> **H3b.** AI adoption does not reduce customer waiting times for stacked deliveries, as efficiency gains are offset by increased order complexity.

---

## C8. 구조적 섹션 누락

- **지적자**: R2 (#11), AE ("immature state")
- **심각도**: CRITICAL

### 무엇을
결론(Conclusion), 한계점(Limitations), 이론적 기여(Theoretical Contributions), 실무적 시사점(Managerial Implications) 섹션을 모두 신규 작성한다.

### 어디를
- **Section 7 (토론)**: 7.1 핵심 발견, 7.2 이론적 기여, 7.3 실무적 시사점, 7.4 사회적 영향 논의
- **Section 8 (결론)**: 8.1 핵심 시사점, 8.2 한계점, 8.3 향후 연구 -- 전부 신규

### 근거
- `docs/09-paper-architecture.md` (Section 7--8 구조 설계)
- `output/tables/table4_daily_productivity.csv`: DDD 결과 (중숙련 상호작용 p = 0.095)
- `output/tables/inequality_overall.csv`: Gini/Theil 변화
- `output/tables/table7_waiting_time.csv`: 고객 대기시간 비유의

### 참고 텍스트

**Section 7.2 -- 이론적 기여:**

> This study makes three theoretical contributions. First, we provide a task-based mechanism for heterogeneous AI effects on platform workers. By decomposing the delivery workflow into constituent task components and identifying which component AI automates, we explain why medium-proficiency riders benefit most: AI resolves their binding constraint (order selection) while their execution competence allows them to capitalize on better-matched orders. This mechanism extends the task-based framework (Autor et al., 2003; Acemoglu & Autor, 2011) to the platform economy context.
>
> Second, we offer the first empirical evidence on the distributional consequences of ML-based -- as distinct from rule-based or optimization-based -- task assignment in platform labor markets. Prior studies have examined algorithmic assignment (Chen et al., 2024) and dispatch optimization (Mao et al., 2025), but neither incorporated the learning, personalization, and dynamic updating that characterize AI systems.
>
> Third, we document that AI-driven task assignment produces a progressive distributional pattern -- compressing the productivity distribution -- even absent explicit equity-oriented design, contributing to the emerging literature on unintended distributional consequences of AI adoption (Brynjolfsson et al., 2025; Noy & Zhang, 2023).

**Section 7.3 -- 실무적 시사점:**

> For platform operators, our findings suggest that AI-driven task assignment yields differential returns across worker proficiency levels, with the largest gains concentrated among medium-proficiency workers. To extend benefits to low-proficiency workers, platforms may need to complement algorithmic order matching with support for downstream task components -- navigation assistance, sequencing guidance, or training programs targeting execution skills.
>
> For policymakers, our results indicate that AI adoption in platform labor markets can partially attenuate -- but does not eliminate -- productivity inequality among workers. Regulatory frameworks should account for the proficiency-dependent nature of AI benefits rather than assuming uniform effects.

**Section 8.1 -- 핵심 시사점:**

> This study provides short-run evidence that AI-driven task assignment in food delivery platforms generates heterogeneous effects across worker proficiency levels, with medium-proficiency riders capturing the largest productivity gains. The progressive distributional pattern -- documented through formal inequality decomposition -- arises from a ceiling effect mechanism rather than deliberate equity-oriented design. Customer-side effects remain statistically undetectable within our observation window.

**Section 8.2 -- 한계점:**

> Our study is subject to several limitations. First, the observation window of one month before and after AI introduction constrains our ability to distinguish transient effects from durable behavioral changes and to detect long-run learning dynamics. Second, our analysis covers a single delivery platform in one country, limiting cross-platform and cross-national generalizability. Third, despite four complementary robustness analyses, our quasi-experimental design cannot definitively rule out all forms of time-varying unobservable selection; our estimates should be interpreted as the ATT rather than the ATE. Fourth, we lack GPS trajectory and routing data that would enable direct measurement of navigation efficiency. Fifth, our customer-side estimates are conditional on assignment to AI-adopting riders and do not capture platform-wide general equilibrium effects.

**Section 8.3 -- 향후 연구:**

> Future research should pursue longer observation periods to establish the persistence and evolution of AI-driven productivity effects; cross-platform comparisons to assess generalizability; investigation of complementary interventions (e.g., navigation support) for low-proficiency workers; analysis of long-run learning dynamics and skill development; and estimation of platform-wide equilibrium effects on consumer welfare using comprehensive platform data.

---

## C9. 문헌 리뷰가 비판적이지 않음

- **지적자**: R2 (#4, #5), AE (암묵적)
- **심각도**: HIGH

### 무엇을
문헌 리뷰를 "나열형"에서 "논쟁(debate) 중심"으로 재구성하고, 플랫폼 특화 인용 15--20개를 추가한다. 상충 결과(conflicting findings)를 비판적으로 평가한다.

### 어디를
- **Section 2.1**: AI vs 알고리즘 디스패치 구분 문헌 (신규 인용 3개)
- **Section 2.2**: "AI와 근로자 성과: 상충 증거" (신규 인용 4개)
- **Section 2.3**: 이질적 효과 문헌 (신규 인용 3개)
- **Section 2.4**: 근로자-고객 연계 문헌 (신규 인용 3개)

### 근거
- `docs/12-new-references.md` (18개 신규 인용 목록 및 삽입 위치)
- `docs/11-fact-check.md` (기존 인용 정확성 검증)
  - Brynjolfsson et al.: "+30%" → "+34%" 수정 필요
  - Dell'Acqua et al.: "inside the frontier" 조건 병기 필요

### 참고 텍스트

**Section 2.2 -- 상충 증거 (비판적 종합):**

> The evidence on AI's impact on worker performance is far from univocal. Two competing perspectives have emerged. The *skill-leveling view* holds that AI disproportionately benefits lower-performing workers, compressing the productivity distribution (Brynjolfsson et al., 2025; Noy & Zhang, 2023; Dell'Acqua et al., 2023). The *skill-amplifying view* contends that AI magnifies existing advantages, as higher-skilled workers leverage AI tools more effectively (Acemoglu et al., 2022).
>
> Critically, these studies differ along dimensions that may explain their divergent findings. First, the *type of AI* varies: Brynjolfsson et al. (2025) study generative AI for cognitive tasks, while our context involves ML-based task assignment for physical delivery. Second, the *task boundary* matters: Dell'Acqua et al. (2023) show that the leveling effect obtains only for tasks within AI's capability frontier; for tasks outside it, AI access actually harms below-average performers. Third, the *worker agency* dimension differs: in Noy and Zhang (2023), workers directly interact with AI output, whereas in platform task assignment, the AI operates as an intermediary between demand and supply. Fourth, Zhou et al. (2025) document dual effects of algorithmic management -- efficiency gains coexisting with autonomy reduction -- suggesting that net effects depend on the specific mechanism through which AI interacts with workers.
>
> This heterogeneity in findings motivates our study's focus on identifying the specific *task component* that AI automates and theorizing how the locus of automation shapes distributional outcomes.

**인용 정확성 수정 (팩트체크 반영):**

> Brynjolfsson et al. (2025) report that generative AI assistance improved the productivity of low-ability customer service agents by 34% (with an overall average improvement of 14%), while leaving high-ability agents' net performance largely unchanged.

> Dell'Acqua et al. (2023) found that below-average consultants gained 43% from GPT-4 assistance versus 17% for above-average consultants; however, this leveling effect was limited to tasks *within* the AI's capability frontier.

---

# Part 2. AE 고유 지적 (AE-1, AE-2, AE-3)

---

## AE-1. "Labour Skill" 용어 오해 유발

- **심각도**: CRITICAL
- **수렴 이슈**: C1과 동일

### 무엇을
C1 참조. "proficiency level"로 전체 교체 + 과업 기반 이론적 근거 보강.

### 어디를
C1과 동일.

### 근거
C1과 동일. AE 원문: "I have serious reservations regarding the study's theoretical setting, particularly the definition of 'labour skill.' A more accurate classification would be 'high,' 'medium,' and 'low' performance."

### 참고 텍스트 (Response Letter)

> We fully agree with the Associate Editor that our original framing of pre-adoption productivity-based classification as "skill" was imprecise and potentially misleading. In the revised manuscript, we classify riders by "delivery proficiency level" and provide an explicit definition grounded in the task-based theoretical framework (Autor et al., 2003; Acemoglu & Autor, 2011). We chose "proficiency" over "performance" because our theoretical argument -- that AI benefits depend on the interaction between automated and non-automated task components -- requires a concept that captures accumulated task competence rather than a bare observed output metric. Section 3.3 now details the operationalization and Section 2.3 provides the theoretical justification.

---

## AE-2. 연구 목적 불명확; 근로자-고객 상호관계 미조사

- **심각도**: CRITICAL
- **수렴 이슈**: C7 (연구 목적), C3 (소비자 측)과 부분 중복

### 무엇을
(1) 서론을 3개 RQ로 재구성 (C7 참조), (2) 근로자-고객 연계 분석을 추가하거나, 데이터 제약으로 불가 시 명시적으로 인정하고 향후 연구로 제안한다.

### 어디를
- **Section 1**: RQ 재구성 (C7 참조)
- **Section 2.4**: 근로자-고객 연계 이론 보강
- **Section 5.4**: 매개 분석 또는 연관 분석 (데이터 허용 시 신규)
- **Section 8.2**: 한계점에 연계 미비 명시

### 근거
- `docs/09-paper-architecture.md` (Section 5.4 설계)
- `docs/12-new-references.md` (Section 2.4 인용: Cohen et al. 2022, Allon et al. 2023, Cachon et al. 2017)
- `output/tables/table7_waiting_time.csv`: 고객 대기시간 비유의

### 참고 텍스트

**Section 2.4 -- 근로자-고객 연계 이론:**

> The mechanism through which worker-side efficiency gains may -- or may not -- translate into improved customer experiences warrants explicit theorization. In food delivery, the link between worker productivity and customer outcomes is mediated by rider strategic behavior. Cohen et al. (2022) demonstrate that waiting time causally affects customer behavior in ride-hailing, establishing a direct worker-efficiency-to-customer-experience channel. However, Allon et al. (2023) show that gig workers' behavioral responses to incentives can be non-linear, suggesting that productivity gains may be redirected toward increased earnings (accepting more orders) rather than faster individual deliveries.
>
> We hypothesize that the worker-to-customer transmission depends on the delivery type. For single-order deliveries, higher worker efficiency should directly reduce customer waiting time. For stacked (multi-order) deliveries, efficiency gains may be absorbed by riders accepting additional orders, leaving per-customer waiting time unchanged or even increased.

**Section 5.4 -- 근로자-고객 연계 (데이터 제약 시):**

> A direct mediation analysis linking worker productivity gains to customer experience outcomes would require rider-customer matched panel data with sufficient within-rider variation. Our data structure -- which identifies customers at the order level but lacks repeated customer observations -- limits our ability to estimate formal mediation models. We therefore present the worker-side (Tables 4-6) and customer-side (Table 7) results as complementary but not formally linked analyses, and flag the estimation of the worker-to-customer transmission mechanism as a priority for future research with richer data.

---

## AE-3. AI 구현 상세 없이 사회적 영향 주장 투기적

- **심각도**: CRITICAL
- **수렴 이슈**: C4 (AI 불명확) + C5 (사회적 평등 투기적)

### 무엇을
(1) AI 기술 구조 하위 섹션 신설 (C4 참조), (2) 사회적 평등 주장 축소 및 재프레이밍 (C5 참조).

### 어디를
C4 + C5 참조.

### 근거
C4 + C5 참조. AE 원문: "If AI is not specifically designed for social equality, it is unlikely that it will organically work for such a purpose."

### 참고 텍스트 (Response Letter)

> We address the Associate Editor's concern on two fronts. First, we have added Section 3.1.1, which specifies the three technical properties that distinguish our platform's system from conventional algorithmic dispatch: revealed preference estimation via supervised learning, personalized rider-order matching, and dynamic model updating. We contrast this with rule-based and optimization-based systems studied in prior work (Chen et al., 2024; Mao et al., 2025).
>
> Second, we have substantially revised our framing of distributional implications. We no longer claim that AI promotes "social equality." Instead, we document a *progressive distributional pattern* -- a compression of the productivity distribution -- and provide a task-based mechanism explanation (ceiling effect in the automated task component). We cite multiple studies where AI tools produced inequality-reducing effects absent equity-oriented design intent (Brynjolfsson et al., 2025; Noy & Zhang, 2023; Dell'Acqua et al., 2023), invoking Merton's (1936) framework of unanticipated consequences.

---

# Part 3. R1 지적 (Major 1--4, Minor 1--3)

---

## R1-Major 1. 기여도 포지셔닝 불분명

- **심각도**: HIGH

### 무엇을
기여도를 "이질적 효과 + 과업 기반 메커니즘"으로 명확히 포지셔닝한다. 기존 AI-노동 문헌과의 차별점을 구체화한다.

### 어디를
- **Section 1.5 (기여 미리보기)**: 재작성
- **Section 7.2 (이론적 기여)**: 3가지 기여 명시

### 근거
- `docs/09-paper-architecture.md` (Section 1.5, 7.2 설계)
- `docs/05-ai-vs-dispatch.md` (포지셔닝)

### 참고 텍스트

**Section 1.5 -- 기여 미리보기:**

> This study contributes to the emerging literature on AI in platform labor markets in three specific ways. First, we develop a task-based mechanism that explains *why* AI-driven task assignment generates heterogeneous productivity effects across worker proficiency levels -- an explanation grounded in which task component the AI automates and which it leaves to human execution. Second, we provide the first empirical evidence on ML-based (as distinct from rule-based or optimization-based) task assignment using granular operational data from a food delivery platform. Third, we document and formally measure the distributional consequences of AI adoption using inequality decomposition methods (Gini, Theil), moving beyond average treatment effects to characterize how AI reshapes the productivity distribution.

---

## R1-Major 2. AI vs 기존 알고리즘 디스패치 구분 필요

- **심각도**: CRITICAL
- **수렴 이슈**: C4와 동일

### 무엇을
C4 참조.

### 어디를
C4 참조.

### 근거
C4 참조.

### 참고 텍스트
C4 참조.

---

## R1-Major 3. 내생성 / Event-Study / 처리 강도 / Oster Bounds

- **심각도**: CRITICAL
- **수렴 이슈**: C2와 동일

### 무엇을
C2 참조. 세부 항목:
- **R1-3A**: Event-study / 동적 DID → `output/interpretation/01-event-study.md`
- **R1-3B**: 처리 강도 용량-반응 → `output/interpretation/03-dose-response.md`
- **R1-3C**: Oster bounds + 안정 근로자 → `output/interpretation/02-oster-bounds.md`, `output/interpretation/04-stable-workers.md`

### 어디를
C2 참조.

### 근거
C2 참조.

### 참고 텍스트
C2 참조.

---

## R1-Major 4. 소비자 후생 주장 과대

- **심각도**: HIGH
- **수렴 이슈**: C3과 동일

### 무엇을
C3 참조.

### 어디를
C3 참조.

### 근거
C3 참조.

### 참고 텍스트
C3 참조.

---

## R1-Minor 1. 참고문헌 중복 (Chen 2024a/b)

- **심각도**: LOW

### 무엇을
Chen (2024) 중복 항목을 정리한다. 동일 논문의 working paper 버전과 저널 버전이 별도로 인용된 경우, 저널 버전만 유지한다.

### 어디를
- **참고문헌(References)**: 중복 항목 제거
- **본문 인용**: 단일 인용으로 통합

### 근거
- `docs/02-severity-matrix.md` (R1-M1)
- `docs/11-fact-check.md` #5: Chen et al. (2024) 제목에 AI 없음, "algorithmic assignment" 사용

### 참고 텍스트

> Chen, Z., Tong, J., & Xu, J. (2024). Impacts of algorithmic assignment on driver behavior. *[Journal name]*.
>
> [Note: Remove the duplicate entry. Retain only the most recent published version. If both are working papers, retain the one with the SSRN DOI and note the access date.]

---

## R1-Minor 2. 불평등 지표 (Gini/Theil) 공식 분해

- **심각도**: MEDIUM

### 무엇을
Gini 계수, Theil 지수, P90/P10 비율을 공식적으로 보고하고, 처리군/통제군별 분해를 제시한다.

### 어디를
- **Section 6.5 (불평등 지표)**: 신규 하위 섹션
- **Table (신규)**: 불평등 지표 요약

### 근거
- `output/interpretation/05-inequality.md`
- `output/tables/inequality_metrics.csv`: 그룹별 상세 (AI 채택자 Gini: 0.160→0.150; 비채택자: 0.241→0.147)
- `output/tables/inequality_overall.csv`: 전체 Gini: 0.181→0.152, Theil: 0.128→0.055
- `output/figures/inequality_density.png`: 밀도 분포 그림

### 참고 텍스트

**Section 6.5 -- 불평등 지표:**

> To formally assess the distributional consequences of AI adoption, we compute the Gini coefficient, Theil index, and P90/P10 ratio for hourly productivity before and after AI introduction (Table [X]). The overall Gini coefficient declined from 0.181 to 0.152 (Delta = -0.029), and the Theil index from 0.128 to 0.055 (Delta = -0.073), indicating a substantial compression of the productivity distribution. The P90/P10 ratio narrowed from 1.970 to 1.836. Figure [X] displays kernel density estimates of the productivity distribution before and after AI adoption, visually confirming the compression pattern.
>
> Decomposing by treatment status, AI adopters experienced a Gini decline from 0.160 to 0.150, while non-adopters showed a larger decline from 0.241 to 0.147. The latter finding warrants cautious interpretation, as the non-adopter post-period sample is substantially smaller (n = 106 vs. 229 pre-period), and the decline may partly reflect compositional changes in the non-adopter pool.

---

## R1-Minor 3. 소비자 고정효과 명세

- **심각도**: MEDIUM

### 무엇을
소비자 측 회귀 모형의 고정효과 구조를 명확히 기술한다. 고객 고정효과 포함 여부, 군집 수준, 추정량의 의미를 주석으로 추가한다.

### 어디를
- **Section 4.4 (소비자 측 명세)**: 신규 또는 확장
- **Table 7 주석**: 고정효과 명세 추가

### 근거
- `docs/02-severity-matrix.md` (R1-M3)
- `docs/09-paper-architecture.md` (Section 4.4 설계)
- `output/tables/table7_waiting_time.csv`: 3가지 명세 (all, single, stacked)

### 참고 텍스트

**Section 4.4 -- 소비자 측 명세:**

> For customer-side outcomes, we estimate:
>
> WaitingTime_{ijt} = alpha + beta * AI_Adopt_{it} + X_{it}'gamma + mu_s + lambda_t + epsilon_{ijt}
>
> where i indexes riders, j indexes orders (and their associated customers), t indexes dates, mu_s denotes station fixed effects, and lambda_t denotes date fixed effects. We do not include customer fixed effects because most customers appear only once in our sample, precluding within-customer identification. Standard errors are clustered at the rider level to account for within-rider correlation across orders. The coefficient beta captures the average difference in waiting time for orders delivered by AI-adopting riders relative to matched non-adopters, conditional on station-date fixed effects -- i.e., the treatment effect on customers *served by treated riders*, not on the general customer population.

---

# Part 4. R2 지적 (1--11)

---

## R2-1. 서론에서 증거 전에 AI "가치 창출" 단언

- **심각도**: MEDIUM

### 무엇을
서론 도입부에서 AI의 긍정적 효과를 단정하는 표현을 의문형으로 바꾼다. 알고리즘 관리의 부정적 측면도 병기한다.

### 어디를
- **Section 1.1 (도입)**: 첫 문단

### 근거
- `docs/09-paper-architecture.md` (Section 1.1 설계: "절대 아닌 것: AI가 가치를 창출하고 생산성을 향상시킨다")
- `docs/12-new-references.md` #7: Zhou et al. (2025) -- 알고리즘 관리의 이중 효과

### 참고 텍스트

> Artificial intelligence is increasingly embedded in the operational infrastructure of platform labor markets, from task allocation and performance monitoring to pricing and customer matching. Whether AI-driven task assignment creates value for all platform stakeholders -- or systematically advantages some at the expense of others -- remains an open empirical question. On one hand, AI may enhance matching efficiency, improving productivity for workers and service quality for customers. On the other hand, algorithmic management can reduce worker autonomy and generate uneven distributional effects (Zhou et al., 2025). This study investigates the heterogeneous effects of AI-driven order assignment across workers of different proficiency levels and examines whether worker-side effects transmit to customer outcomes.

---

## R2-2. 서론에서 근로자만 강조, 고객 논의 지연

- **심각도**: HIGH
- **수렴 이슈**: C7과 부분 중복

### 무엇을
서론에서 근로자와 고객을 병렬로 제시한다. 다중 이해관계자(multi-stakeholder) 프레이밍을 서론 첫 문단부터 도입한다.

### 어디를
- **Section 1.1--1.3**: 근로자-고객 병렬 언급
- **Section 1.4**: RQ3에 고객 포함 (C7 참조)

### 근거
- `docs/09-paper-architecture.md` (Section 1.1--1.4)
- R2 원문: "only mentions workers initially... customer discussion comes much later"

### 참고 텍스트

C7 참조 (RQ1--RQ3), R2-1 참조 (도입 문단). 추가로:

> Platform labor markets involve multiple stakeholders whose outcomes may be differentially affected by AI adoption. Workers experience changes in task allocation, productivity, and earnings; customers experience changes in service quality, waiting times, and satisfaction; and the platform itself faces trade-offs between operational efficiency and equity. This study examines the first two stakeholder groups -- workers and customers -- using matched operational data that links rider-level productivity outcomes to order-level customer experience metrics.

---

## R2-3. 서론에 한계점 논의 부재

- **심각도**: MEDIUM
- **수렴 이슈**: C7과 부분 중복

### 무엇을
서론 마지막에 경계 조건(boundary conditions) 문단을 추가한다.

### 어디를
- **Section 1.6 (경계 조건)**: 신규

### 근거
- `docs/09-paper-architecture.md` (Section 1.6 설계)

### 참고 텍스트
C7의 Section 1.6 참조.

---

## R2-4. 문헌 리뷰 비판적이지 않음

- **심각도**: HIGH
- **수렴 이슈**: C9와 동일

### 무엇을
C9 참조.

### 어디를
C9 참조.

### 근거
C9 참조.

### 참고 텍스트
C9 참조.

---

## R2-5. 플랫폼 특화 연구 대신 일반 연구 인용

- **심각도**: HIGH
- **수렴 이슈**: C9와 동일

### 무엇을
플랫폼 특화 인용 15--20개를 추가한다. 일반 AI 연구에만 의존하는 것이 아니라, 긱 이코노미/플랫폼 노동 맥락의 실증 연구를 중심으로 보강한다.

### 어디를
- **Section 2 전체**: 각 하위 섹션에 배분

### 근거
- `docs/12-new-references.md` (18개 신규 인용 전체 목록)
  - Section 2.1: Raisch & Krakowski (2021), Berente et al. (2021), Autor et al. (2003)
  - Section 2.2: Horton (2023), Acemoglu et al. (2022), Burtch et al. (2018), Zhou et al. (2025)
  - Section 2.3: Acemoglu & Autor (2011), Cui et al. (2023), Cowgill & Tucker (2020)
  - Section 2.4: Cohen et al. (2022), Allon et al. (2023), Cachon et al. (2017)
  - Section 7: Merton (1936), Oster (2019), Sun & Abraham (2021), Callaway & Sant'Anna (2021), Russell & Norvig (2021)

### 참고 텍스트

아래는 Section 2.2에 삽입할 플랫폼 특화 문단 예시:

> Within platform labor markets specifically, the evidence base is growing but fragmented. Burtch et al. (2018) provide causal evidence on gig economy entry effects on labor markets, establishing the empirical foundations for studying platform worker behavior. In the ride-hailing context, Allon et al. (2023) demonstrate that behavioral drivers -- income targets, time targets -- significantly shape gig workers' labor supply decisions, complicating simple productivity comparisons. Cohen et al. (2022) show that customer waiting times causally affect retention in ride-sharing, establishing the worker-efficiency-to-customer-experience link that motivates our RQ3. Notably, existing platform studies of algorithmic assignment (Chen et al., 2024; Mao et al., 2025) examine systems that lack the learning and personalization components present in our context, leaving a gap in understanding how ML-based AI -- as distinct from deterministic algorithms -- affects platform stakeholders.

---

## R2-6. 데이터 1개월; 대표성 논의 부재

- **심각도**: HIGH
- **수렴 이슈**: C6과 동일

### 무엇을
C6 참조. 추가로 표본 대표성(representativeness) 논의를 포함한다.

### 어디를
- **Section 3.2 (데이터)**: 기간 정당화 + 대표성 논의 문단
- **부록**: 플랫폼 전체 통계 비교 (데이터 확보 시)

### 근거
- C6 참조
- `docs/09-paper-architecture.md` (Section 3.2: "대표성 분석 vs 플랫폼 전체")

### 참고 텍스트

C6의 Section 3.2 참조. 추가로:

> To assess sample representativeness, we compare our study sample's key characteristics (average daily orders, working hours, earnings) with platform-wide aggregates provided by the company for the same period. [If available: "Our sample riders' average daily productivity of X.XX orders per hour falls within [range] of the platform-wide average of Y.YY, suggesting reasonable representativeness." If unavailable: "We acknowledge that we cannot formally assess representativeness against platform-wide statistics, as such data were not available under our data access agreement. This limitation should be considered when interpreting the external validity of our findings."]

---

## R2-7. 자기 선택 편의 + 짧은 기간

- **심각도**: CRITICAL
- **수렴 이슈**: C2 + C6 동일

### 무엇을
C2 (식별 전략 보강) + C6 (기간 한계 인정) 참조.

### 어디를
C2 + C6 참조.

### 근거
C2 + C6 참조.

### 참고 텍스트
C2 + C6 참조.

---

## R2-8. 단기 결과 과잉 해석

- **심각도**: HIGH

### 무엇을
결과 해석에서 "단기 증거에 따르면(short-run evidence suggests...)"이라는 한정 표현을 일관되게 사용한다. 장기 효과에 대한 추론을 삭제한다.

### 어디를
- **Section 5 (결과)**: 모든 해석 문단
- **Section 7 (토론)**: 모든 시사점 문단
- **초록**: 결과 요약 문장

### 근거
- `docs/02-severity-matrix.md` (R2-8: "REWRITE: 단기 증거에 따르면...")
- C6 (기간 한계)

### 참고 텍스트

아래 표현 패턴을 모든 결과 해석에 적용:

> Short-run evidence from the first month of AI adoption suggests that... [result]. Whether these effects persist, amplify, or dissipate over longer horizons remains an open question that future research with extended observation windows should address.

**초록 수정 예시:**

> Using one month of pre- and post-adoption operational data, we find short-run evidence that AI-driven task assignment generates heterogeneous productivity effects: medium-proficiency riders capture the largest gains, consistent with a task-based ceiling effect mechanism. These short-run patterns are suggestive but should not be extrapolated to longer time horizons without further evidence.

---

## R2-9. 학습 곡선 주장에 실증 근거 없음

- **심각도**: MEDIUM

### 무엇을
기간 내 학습 역학 분석(주차별 처리 효과)을 추가한다. 통계적 유의성 부족을 솔직히 인정하되, 패턴의 방향성을 보고한다.

### 어디를
- **Section 6.6 (기간 내 역학)**: 신규 하위 섹션

### 근거
- `output/interpretation/06-learning-dynamics.md`
- `output/tables/learning_dynamics.csv`:
  - Week 1: +0.079 (p=0.374), Week 2: -0.028 (p=0.755), Week 3: -0.065 (p=0.470), Week 4: +0.284 (p=0.407)
  - 시간-효과 상관: 0.477

### 참고 텍스트

C6의 Section 6.6 참조.

---

## R2-10. 단일 과업/플랫폼/국가

- **심각도**: MEDIUM

### 무엇을
외적 타당성(external validity) 한계를 명시적으로 인정하는 소절을 추가한다.

### 어디를
- **Section 8.2 (한계점)**: 2번째 항목

### 근거
- `docs/02-severity-matrix.md` (R2-10: "ACKNOWLEDGE: 한계점 소섹션")
- `docs/09-paper-architecture.md` (Section 8.2)

### 참고 텍스트

> Second, our analysis is based on a single food delivery platform in one country (South Korea), performing a single primary task type (food delivery). The extent to which our findings generalize to other platform types (ride-hailing, freelance marketplaces), other task structures (multi-step services, creative work), or other institutional and cultural contexts remains unknown. Food delivery involves a relatively standardized physical task with limited scope for creative application of AI tools, which may limit the applicability of our task-based mechanism to knowledge-intensive platform work. Cross-platform and cross-national replication studies are needed to establish the generalizability of these findings.

---

## R2-11. 결론/시사점/한계점 섹션 없음

- **심각도**: CRITICAL
- **수렴 이슈**: C8과 동일

### 무엇을
C8 참조.

### 어디를
C8 참조.

### 근거
C8 참조.

### 참고 텍스트
C8 참조.

---

# 부록: 분석 결과 파일 참조표

모든 `output/` 파일과 대응하는 수정 지적사항의 매핑입니다.

| 파일 경로 | 내용 | 대응 지적 |
|-----------|------|----------|
| `output/interpretation/01-event-study.md` | Event-study 분석 해석 | C2, R1-3A |
| `output/interpretation/02-oster-bounds.md` | Oster bounds 분석 해석 | C2, R1-3C, R2-7 |
| `output/interpretation/03-dose-response.md` | 용량-반응 분석 해석 | C2, R1-3B |
| `output/interpretation/04-stable-workers.md` | 안정 근로자 분석 해석 | C2, R1-3C, R2-7 |
| `output/interpretation/05-inequality.md` | Gini/Theil 불평등 분해 해석 | C5, R1-M2 |
| `output/interpretation/06-learning-dynamics.md` | 기간 내 학습 역학 해석 | C6, R2-9 |
| `output/tables/event_study_coefficients.csv` | Event-study 주별 계수 | C2, R1-3A |
| `output/tables/oster_bounds.csv` | Oster bounds 결과 | C2, R1-3C |
| `output/tables/dose_response_quartiles.csv` | 용량-반응 사분위 결과 | C2, R1-3B |
| `output/tables/stable_workers.csv` | 안정 근로자 추정치 | C2, R1-3C |
| `output/tables/inequality_metrics.csv` | 그룹별 불평등 지표 | C5, R1-M2 |
| `output/tables/inequality_overall.csv` | 전체 불평등 지표 | C5, R1-M2 |
| `output/tables/learning_dynamics.csv` | 주차별 학습 효과 | C6, R2-9 |
| `output/tables/table4_daily_productivity.csv` | DID/DDD 생산성 결과 | C1, C7, R1-1 |
| `output/tables/table5_shift_behavior.csv` | 스택 수준 행동 변화 | C1 |
| `output/tables/table6_day_behavior.csv` | 일 수준 행동 변화 | C1, C8 |
| `output/tables/table7_waiting_time.csv` | 고객 대기시간 결과 | C3, R1-4, AE-2 |
| `output/figures/event_study_productivity.png` | Event-study 그림 | C2, R1-3A |
| `output/figures/dose_response.png` | 용량-반응 그림 | C2, R1-3B |
| `output/figures/inequality_density.png` | 불평등 밀도 분포 그림 | C5, R1-M2 |

---

# 부록: 팩트체크 기반 즉시 수정 사항

`docs/11-fact-check.md`에서 확인된 인용 오류를 즉시 수정해야 합니다.

| # | 현재 표현 | 수정 표현 | 근거 |
|---|----------|----------|------|
| 1 | Brynjolfsson et al.: "+30%" | "+34%" (또는 "약 14% 평균, 저숙련 34%") | QJE 최종판 확인 |
| 2 | Knight et al.을 "skill 미사용" 근거로 인용 | 삭제. ISR 저널판 제목에 "Skill Level" 명시 | ISR 저널판 확인 |
| 3 | Dell'Acqua et al. 인용 시 조건 미병기 | "inside the frontier 과제 한정" 조건 추가 | HBS WP 확인 |

---

# 부록: 수정 우선순위 요약

| 우선순위 | 지적 | 심각도 | 작업량 | 비고 |
|---------|------|--------|--------|------|
| 1 | C2 (내생성) | CRITICAL | 대 | 4가지 신규 분석 -- 이미 완료, 결과 삽입만 필요 |
| 2 | C4 (AI 정의) | CRITICAL | 중 | Section 3.1.1 신설 + 비교표 |
| 3 | C1 (용어) | CRITICAL | 중 | 전체 교체 + 이론 보강 |
| 4 | C7 (연구 목적) | CRITICAL | 중 | 서론 재구성 |
| 5 | C8 (구조 누락) | CRITICAL | 대 | Section 7--8 신규 작성 (3--5 페이지) |
| 6 | R2-11 | CRITICAL | 대 | C8과 동일 |
| 7 | R2-7 | CRITICAL | - | C2+C6 중복 |
| 8 | C3 (소비자 과대) | HIGH | 소 | 표현 수정 위주 |
| 9 | C5 (사회적 평등) | HIGH | 중 | 재프레이밍 + 메커니즘 |
| 10 | C6 (짧은 기간) | HIGH | 중 | 인정 + 정당화 + 역학 분석 |
| 11 | C9 (문헌 리뷰) | HIGH | 대 | 재구성 + 신규 인용 18개 |
| 12 | R1-1 (기여도) | HIGH | 소 | 포지셔닝 재작성 |
| 13 | R2-1 (단언) | MEDIUM | 소 | 의문형 전환 |
| 14 | R2-8 (과잉 해석) | HIGH | 소 | "단기 증거" 한정 |
| 15 | R1-M2 (불평등 지표) | MEDIUM | 소 | 분석 완료, 결과 삽입 |
| 16 | R1-M3 (소비자 FE) | MEDIUM | 소 | 주석 추가 |
| 17 | R2-9 (학습 곡선) | MEDIUM | 소 | 분석 완료, 결과 삽입 |
| 18 | R2-10 (외적 타당성) | MEDIUM | 소 | 한계점 문단 |
| 19 | R1-M1 (중복 제거) | LOW | 소 | 참고문헌 정리 |
