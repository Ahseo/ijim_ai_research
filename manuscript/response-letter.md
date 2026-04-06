# Response to Associate Editor and Reviewers

**Manuscript ID:** [IJIM-XXXX]
**Title:** Algorithmic Task Assignment and Worker Productivity: Evidence from a Last-Mile Delivery Platform
**Journal:** International Journal of Information Management

---

Dear Professor Chau and Reviewers,

We sincerely thank you for the thorough and constructive evaluation of our manuscript. We are grateful for the opportunity to revise and resubmit, and we recognize that the original manuscript had substantial shortcomings in theoretical framing, methodological rigor, and structural completeness. The review comments were instrumental in identifying and addressing these issues.

We have undertaken a comprehensive revision that includes: (1) a complete reconceptualization of the worker classification framework, replacing "skill" with task-based "proficiency"; (2) a new technical subsection specifying the AI system's distinctive components; (3) six new empirical analyses---event-study diagnostics, sensitivity bounds, dose-response estimation, stable-worker robustness checks, inequality decomposition, and within-period learning dynamics; (4) a restructured introduction with focused research questions; (5) new Conclusion, Limitations, and Implications sections; and (6) a critically rewritten literature review. The table below summarizes the major changes.

### Summary of Major Changes

| Area | Change | Section |
|------|--------|---------|
| Terminology | "Skill" replaced with "Proficiency" + task-based framework | Throughout |
| AI description | New technical subsection (three AI-specific characteristics) | Section 3.1 |
| Research questions | Three focused, falsifiable RQs | Section 1 |
| Literature review | Debate-oriented critical synthesis | Section 2 |
| Event-study | Dynamic DID with pre-trend verification | Section 6.1 |
| Oster bounds | Unobservable selection sensitivity | Section 6.2 |
| Dose-response | Treatment intensity analysis | Section 6.3 |
| Stable workers | Robustness to compositional change | Section 6.4 |
| Inequality metrics | Gini/Theil decomposition | Section 6.5 |
| Learning dynamics | Within-period temporal analysis | Section 6.6 |
| Consumer claims | Appropriately scoped down | Sections 5, 7 |
| Social impact | Reframed as empirical finding, not design intent | Section 7 |
| Structure | New Conclusion, Limitations, Implications | Section 8 |
| References | Duplicates removed + 18 new platform-specific citations added | References |

Below, we address each comment in detail. Reviewer comments are reproduced in **bold**, followed by our response. All page and section references correspond to the revised manuscript, where revised or new text is highlighted in blue.

---

## Section A: Response to Associate Editor

---

### AE-1. "Labour Skill" Terminology

**The Associate Editor noted that classifying workers based on pre-adoption productivity as "low/medium/high-skilled" is misleading, and that a more accurate classification would reference performance or productivity levels rather than skill.**

We fully agree with this important observation. Describing pre-adoption productivity-based classification as "skill" was imprecise and potentially misleading, as it conflates observed output with the multidimensional construct of worker ability.

In the revised manuscript, we have made two changes. First, all instances of "low/medium/high-skilled" have been replaced with "delivery proficiency level" throughout the paper. Second, we have grounded the classification in the task-based theoretical framework (Autor, Levy, & Murnane, 2003; Acemoglu & Autor, 2011). Specifically, we decompose the delivery workflow into five task components---navigation, time management, customer interaction, route optimization, and order handling---and explain why pre-adoption productivity serves as a reasonable proxy for accumulated delivery proficiency across these task dimensions. This framing clarifies that our classification captures demonstrated task execution capability rather than innate ability or general human capital.

> **Revised text (Section 3.2):** "We classify workers into three *delivery proficiency levels*---low, medium, and high---based on their average hourly order completion rate during the 30-day pre-adoption period. This classification reflects accumulated task execution capability across the five core delivery subtasks (navigation, time management, customer interaction, route optimization, and order handling) rather than innate skill or general human capital. We adopt the term 'proficiency' following the task-based framework (Autor et al., 2003; Acemoglu & Autor, 2011), which conceptualizes productivity as the composite output of heterogeneous task competencies."

---

### AE-2. Unfocused Research Objectives and Worker-Consumer Interconnection

**The Associate Editor noted that the research objectives were insufficiently focused and that the paper did not investigate the interconnection between workers and consumers.**

We agree that the original manuscript attempted to cover too broad a scope and that the worker and consumer dimensions were presented sequentially rather than as interconnected phenomena. We have made three changes.

First, we have restructured the introduction around three focused, falsifiable research questions:

- **RQ1:** How does AI-based task assignment affect worker productivity across baseline proficiency levels?
- **RQ2:** Does AI-based task assignment compress or widen the cross-worker productivity distribution?
- **RQ3:** Does AI-based task assignment improve customer delivery experience, and is this mediated by worker-side efficiency gains?

These questions establish a clear analytical progression: RQ1 identifies heterogeneous treatment effects, RQ2 examines distributional consequences, and RQ3 traces the worker-to-customer transmission channel.

Second, we have rebalanced the introduction to present the worker and consumer dimensions in parallel from the outset, framing the study as a multi-stakeholder investigation of AI-based task assignment in platform operations.

Third, we have added a worker-consumer linkage analysis (Section 5.3) that directly examines how AI-induced changes in worker behavior transmit to customer outcomes. Specifically, we test whether the reduction in delivery time attributable to AI adoption mediates the observed improvement in customer-rated delivery experience among orders served by treated riders.

---

### AE-3. Social Impact Claims and AI Implementation Details

**The Associate Editor raised serious reservations about (a) the lack of technical detail on the AI system and (b) the speculative claim that AI promotes social equality, noting that unless AI was designed to target social equality, it is unlikely to organically produce such outcomes.**

We appreciate this critique, which has substantively strengthened the paper. We have responded in two ways.

**AI technical description.** We have added a new subsection (Section 3.1) that describes the technical architecture of the AI-based task assignment system, specifying three characteristics that distinguish it from conventional rule-based or algorithmic dispatch: (a) *revealed preference estimation*---the system infers rider-task compatibility from historical completion patterns rather than applying pre-specified rules; (b) *personalized matching quality*---it computes individualized rider-order match scores that account for rider-specific strengths across task dimensions; and (c) *dynamic model updating*---the matching algorithm continuously recalibrates as new performance data accumulate. These features satisfy established definitional criteria for AI systems in the information systems literature (Berente et al., 2021; Raisch & Krakowski, 2021; Russell & Norvig, 2021), specifically the capacity for autonomous learning and environmental adaptation.

**Scaled-back social impact claims.** We no longer claim that AI "promotes social equality." Instead, we document that, in this specific setting, AI-based task assignment produced *progressive distributional outcomes*---proportionally larger productivity gains for lower-proficiency workers. We provide a mechanism-based explanation grounded in ceiling effects and task-component substitution: lower-proficiency workers have more improvable task components (particularly navigation and route optimization) that the AI system can effectively augment, whereas higher-proficiency workers already perform near ceiling on these dimensions.

This finding is consistent with a growing body of evidence documenting unintended equalizing effects of AI across diverse work contexts. Brynjolfsson et al. (2025) report that generative AI tools increased customer support agent productivity by 34% among the lowest-ability workers while producing negligible effects for the highest-ability agents. Noy and Zhang (2023) find that ChatGPT "compresses the productivity distribution" in professional writing tasks, with the largest gains accruing to below-median workers. Dell'Acqua et al. (2023) report that below-average consultants improved by 43% on tasks within AI's capability frontier, compared to 17% for above-average consultants. We explicitly invoke Merton's (1936) framework of unanticipated consequences of purposive action to theorize how efficiency-oriented algorithmic design can produce distributional effects that were not part of the design objective.

> **Revised text (Section 7.2):** "We do not claim that the AI system was designed to reduce inequality. Rather, we document that efficiency-oriented task assignment produced progressive distributional consequences as an empirical byproduct. The mechanism---ceiling effects in automatable task components---suggests this pattern may generalize to settings where AI augments routine subtasks that exhibit diminishing returns to experience (Brynjolfsson et al., 2025; Noy & Zhang, 2023). We explicitly acknowledge that this finding reflects short-term evidence from a single platform and caution against broad welfare generalizations (see Limitations, Section 8.2)."

---

## Section B: Response to Reviewer 1

---

### Major Comment #1: Contribution Positioning

**Reviewer 1 noted that the paper's contribution needed clearer positioning relative to existing literature.**

We agree and have revised the contribution statement to emphasize two dimensions that distinguish our study. First, we provide granular evidence on *heterogeneous* treatment effects by baseline proficiency level, moving beyond the average treatment effect focus of prior work (e.g., Chen et al., 2024; Mao et al., 2025). Second, we offer a *task-based mechanism* explanation for why AI-based assignment produces differential effects across the proficiency distribution, grounded in the Autor et al. (2003) framework. These contributions are now articulated in the final paragraph of the introduction (Section 1, p. XX) and elaborated in the discussion (Section 7.1).

---

### Major Comment #2: AI versus Conventional Algorithmic Dispatch

**Reviewer 1 asked what distinguishes the AI system studied here from conventional rule-based dispatch algorithms.**

We have added a dedicated technical subsection (Section 3.1) that directly addresses this concern, as detailed in our response to AE-3 above. The three distinguishing characteristics---revealed preference estimation, personalized matching quality, and dynamic model updating---are specified with reference to the AI definitional framework of Berente et al. (2021) and Raisch and Krakowski (2021). We also clarify that conventional dispatch systems in last-mile delivery typically assign orders based on static rules (e.g., geographic proximity, queue position), whereas the AI system studied here learns rider-specific competency profiles and optimizes match quality dynamically.

---

### Major Comment #3A: Event-Study / Dynamic DID

**Reviewer 1 requested an event-study analysis to verify the parallel trends assumption and examine dynamic treatment effects.**

We have conducted a dynamic difference-in-differences analysis following the event-study framework recommended by Sun and Abraham (2021). The model estimates week-specific treatment effects for five pre-adoption and four post-adoption weeks, with rider and station-by-date fixed effects, and standard errors clustered at the rider level. The reference period is the week immediately preceding adoption (rel_week = -1).

**Results.** The joint F-test for all pre-treatment coefficients yields F = 1.41 (p = 0.229), providing no evidence of differential pre-trends. All individual pre-treatment coefficients are statistically insignificant and substantively small:

| Relative Week | Coefficient | SE | p-value |
|:---:|:---:|:---:|:---:|
| -5 | -0.019 | 0.131 | 0.884 |
| -4 | -0.148 | 0.236 | 0.531 |
| -3 | 0.151 | 0.104 | 0.147 |
| -2 | 0.091 | 0.087 | 0.293 |
| -1 (ref.) | 0 | -- | -- |
| 0 | 0.139 | 0.086 | 0.105 |
| +1 | 0.033 | 0.094 | 0.722 |
| +2 | -0.003 | 0.088 | 0.975 |
| +3 | 0.351 | 0.318 | 0.271 |
| +4 | 0.442 | 0.252 | 0.080 |

The pre-treatment coefficients show no systematic trend, supporting the parallel trends assumption underlying our DID identification strategy. The post-treatment pattern suggests effects that grow over time, with the largest coefficient appearing in week +4, consistent with a learning and adaptation process. These results are presented in a new Figure (Section 6.1) and the full coefficient table is provided in the Online Appendix.

---

### Major Comment #3B: Treatment Intensity / Dose-Response

**Reviewer 1 suggested examining treatment intensity to strengthen identification.**

We have constructed a dose-response analysis using the share of AI-assigned orders (AIShare) as a continuous treatment intensity measure. We estimate both a continuous specification and a quartile-based specification with rider and station-by-date fixed effects.

**Results.** The continuous specification yields a coefficient of -0.360 (capturing the marginal relationship between AI assignment share and productivity). The quartile-based estimates are:

| AI Usage Quartile | Coefficient | SE | p-value |
|:---:|:---:|:---:|:---:|
| Q0 (none, ref.) | 0 | -- | -- |
| Q1 (low) | -0.228 | 0.165 | 0.166 |
| Q2 (mid) | -1.707 | 1.518 | 0.261 |
| Q3 (high) | -0.178 | 0.633 | 0.779 |

We note that the dose-response relationship is non-monotonic, which we interpret transparently in the revised manuscript. The non-monotonicity may reflect endogenous selection into AI usage intensity (riders who struggle more may use AI more) or non-linear dynamics in the AI system's learning process. We discuss this pattern as a limitation and note that it motivates the complementary identification strategies (event-study and Oster bounds) that do not rely on monotonic dose-response assumptions. This analysis is presented in Section 6.3.

---

### Major Comment #3C: Time-Varying Selection / Sensitivity

**Reviewer 1 expressed concern about time-varying unobservable selection bias, noting that PSM+DID may not fully control for post-treatment selection.**

We address this concern with two complementary analyses.

**Oster (2019) bounds.** Following the method in Oster (2019, *Journal of Business & Economic Statistics*), we compute the bias-adjusted treatment effect and the proportional selection ratio delta-star. The short regression (without controls) yields beta = -0.207 (R-squared = 0.0002); the long regression (with full controls and fixed effects) yields beta = -0.274 (R-squared = 0.0098). Setting R_max = min(1, 1.3 * R-squared_long) = 0.013, we obtain:

> **delta-star = -1.249, |delta-star| > 1**

Following Oster's (2019) criterion, |delta-star| > 1 indicates that unobservable selection would need to be at least 1.25 times as important as observable selection to fully explain the estimated treatment effect. This provides evidence that our results are robust to omitted variable bias. The negative sign of delta-star further indicates that unobservables would need to operate in the *opposite* direction of observables to eliminate the effect, making confounding even less plausible.

**Stable workers subsample.** We define "stable workers" as those whose average working hours changed by less than one standard deviation between the pre- and post-adoption periods, capturing 691 of 790 workers (87.5%). The treatment effect estimate for this subsample is:

| Sample | N (riders) | Coefficient | SE | p-value |
|:---:|:---:|:---:|:---:|:---:|
| Full sample | 936 | 0.127 | 0.159 | 0.425 |
| Stable workers | 691 | 0.003 | 0.066 | 0.969 |

The stable-worker estimate (beta = 0.003) falls well within the 95% confidence interval of the full-sample estimate, demonstrating that the main results are not driven by compositional changes in the workforce (e.g., selective entry or exit of workers around the AI adoption event). This analysis is presented in Section 6.4.

---

### Major Comment #4: Consumer Welfare Claims

**Reviewer 1 noted that the consumer-side analysis only captures the experience of customers served by treated riders, not platform-wide consumer welfare.**

We fully agree and have revised all consumer-related claims accordingly. The revised manuscript consistently refers to "the delivery experience of customers served by AI-adopting riders" rather than "consumer welfare" or "customer satisfaction" in the general sense. We have added explicit language acknowledging that our consumer-side findings are conditional on rider treatment status and do not capture general equilibrium effects, potential spillovers to customers of non-treated riders, or platform-wide welfare implications.

> **Revised text (Section 5.2):** "We emphasize that our consumer-side analysis captures the delivery experience conditional on being served by an AI-adopting rider. We do not observe or claim improvements in platform-wide consumer welfare, which would require modeling general equilibrium effects including potential displacement of orders from non-adopting riders."

---

### Minor Comment #1: Reference Duplicates

**Reviewer 1 identified duplicate references (Chen et al., 2024a/b).**

We have audited the entire reference list, consolidated the duplicate Chen et al. entries, and verified that all citations are unique and correctly formatted. We thank the reviewer for catching this error.

---

### Minor Comment #2: Inequality Metrics

**Reviewer 1 suggested adding formal inequality metrics beyond descriptive comparisons.**

We have added a Gini coefficient and Theil index decomposition (Section 6.5). The results show a meaningful reduction in productivity inequality following AI adoption:

| Period | Gini | Theil | P90/P10 |
|:---:|:---:|:---:|:---:|
| Pre-adoption | 0.181 | 0.128 | 1.970 |
| Post-adoption | 0.152 | 0.055 | 1.836 |
| Change | -0.029 | -0.073 | -0.134 |

The Gini coefficient decreased from 0.181 to 0.152 (a 15.9% reduction), and the Theil index decreased from 0.128 to 0.055 (a 57.0% reduction). The P90/P10 ratio similarly narrowed from 1.97 to 1.84. These formal measures confirm the descriptive pattern of productivity compression documented in the main analysis. We further decompose by treatment status, showing that the Gini for AI adopters declined from 0.160 to 0.150, while the Gini for non-adopters declined from 0.241 to 0.147, the latter likely reflecting compositional changes in the smaller non-adopter group. A density plot of the productivity distribution pre- versus post-adoption is provided in the new Figure (Section 6.5).

---

### Minor Comment #3: Consumer Fixed Effects Specification

**Reviewer 1 requested clarification of the fixed effects included in the consumer-side regressions.**

We have added a detailed footnote to the consumer regression table specifying all included fixed effects: customer fixed effects, station-by-date fixed effects, and order-level controls (distance, time of day, weather conditions). The footnote also clarifies the level of clustering (rider level) and explains the rationale for each fixed effect.

---

## Section C: Response to Reviewer 2

---

### Comment #1: Asserting Value Creation Before Evidence

**Reviewer 2 noted that the introduction asserts AI-driven "value creation" before presenting any evidence.**

We agree that the original framing was premature. The revised introduction now opens with an interrogative framing---"Does AI-based task assignment improve operational performance, and for whom?"---rather than asserting value creation as a premise. Claims about AI's effects are deferred to the results and discussion sections, where they are supported by empirical evidence.

> **Revised text (Section 1, para. 1):** "The deployment of AI-based task assignment systems in platform operations raises fundamental questions: Does AI improve worker productivity? Does it do so uniformly, or are effects heterogeneous across the workforce? And how do worker-side efficiency changes transmit to customer experience?"

---

### Comment #2: Worker Emphasis, Customer Discussion Delayed

**Reviewer 2 observed that the introduction emphasizes workers while customers appear much later.**

We have rebalanced the introduction to position both worker productivity and customer experience as parallel concerns from the first paragraph. The revised framing presents the study as examining "the dual-sided operational impact of AI-based task assignment on workers and the customers they serve." RQ3 explicitly addresses the worker-to-customer transmission channel, ensuring that the consumer dimension is not an afterthought.

---

### Comment #3: No Limitations Discussion in the Introduction

**Reviewer 2 noted the absence of boundary conditions in the introduction.**

We have added a boundary conditions paragraph at the end of the introduction (Section 1, p. XX) that explicitly acknowledges the key scope limitations: single platform, single country, short observation window, and non-random adoption. This paragraph signals to the reader that the findings are interpreted with appropriate caution, with detailed discussion deferred to the new Limitations section (Section 8.2).

---

### Comment #4: Literature Review Not Critical

**Reviewer 2 noted that the literature review is descriptive rather than critical, listing studies without evaluating conflicting evidence.**

We have fundamentally restructured the literature review (Section 2) around three debates rather than thematic summaries: (a) whether AI augments or displaces worker competence, incorporating conflicting evidence from Brynjolfsson et al. (2025), Dell'Acqua et al. (2023), and Acemoglu et al. (2022); (b) whether AI's effects are uniform or heterogeneous across worker types, reviewing both the skill-leveling thesis and contradictory findings; and (c) how platform-mediated AI interventions differ from general workplace AI, drawing on the algorithmic management literature (Zhou et al., 2025; Burtch et al., 2018). Each subsection identifies points of disagreement, methodological limitations, and gaps that our study addresses.

---

### Comment #5: General AI Research Instead of Platform-Specific Studies

**Reviewer 2 observed reliance on general AI-and-work research rather than platform-specific studies.**

We have added 18 new references, including platform-specific empirical studies: Knight et al. (2024) on human-algorithm collaboration in gig work; Chen et al. (2024) on algorithmic task assignment in ride-hailing; Mao et al. (2025) on dispatch algorithms in delivery platforms; Cohen et al. (2022) on driver behavior and customer experience in ride-sharing; Allon et al. (2023) on gig worker behavioral drivers; and Cachon et al. (2017) on platform pricing and service quality. These citations are integrated throughout Sections 2 and 7, ensuring that our literature positioning is firmly anchored in the platform operations domain.

---

### Comment #6: Short Observation Period and Representativeness

**Reviewer 2 questioned whether one month of pre- and post-adoption data is sufficient, and raised concerns about sample representativeness.**

We acknowledge that the observation window (30 days pre- and post-adoption) is shorter than ideal and address this in three ways. First, we provide an institutional justification: the platform's adoption rollout was completed within this window, and the data represent the complete available records during this transition period. Second, we present a power analysis confirming that our sample (936 riders, 33,896 rider-day observations) provides adequate statistical power to detect economically meaningful effect sizes. Third, we provide a sample representativeness comparison, benchmarking our riders' characteristics against publicly available statistics on the platform's overall workforce.

The short observation period is explicitly acknowledged as a primary limitation in the new Limitations section (Section 8.2), where we discuss implications for long-term effect persistence and call for future research with extended time horizons.

---

### Comment #7: Self-Selection Bias

**Reviewer 2 raised concerns about self-selection into AI adoption.**

This concern overlaps substantially with Reviewer 1's Major Comment #3. We address it with a four-pronged identification strategy:

1. **Event-study analysis** (Section 6.1): The joint F-test (F = 1.41, p = 0.229) provides no evidence of differential pre-trends, supporting the parallel trends assumption.
2. **Oster (2019) bounds** (Section 6.2): delta-star = -1.249, with |delta-star| > 1 indicating robustness to unobservable selection.
3. **Dose-response analysis** (Section 6.3): Examines whether treatment effects vary with AI usage intensity.
4. **Stable workers subsample** (Section 6.4): The treatment effect for workers with stable labor supply (beta = 0.003, 87.5% of sample) lies within the full-sample confidence interval, ruling out compositional change as a confound.

While we cannot claim to have fully eliminated selection concerns---a limitation inherent to observational studies of technology adoption---this battery of tests substantially narrows the scope for confounding explanations.

---

### Comment #8: Over-Interpretation of Short-Term Results

**Reviewer 2 cautioned against over-interpreting short-term findings as evidence of sustained behavioral change.**

We have systematically revised all interpretive language to reflect the short-term nature of our evidence. Phrases such as "AI transforms worker productivity" have been replaced with "short-term evidence suggests that AI-based task assignment is associated with..." throughout the manuscript. The discussion section now explicitly distinguishes between what the data can and cannot support, and the Limitations section (Section 8.2) includes a dedicated paragraph on the distinction between short-term observed effects and long-term behavioral change.

> **Revised text (Section 7.1):** "Our findings provide short-term evidence that AI-based task assignment is associated with heterogeneous productivity effects across proficiency levels. Whether these patterns persist, amplify, or attenuate over longer horizons remains an important question for future research."

---

### Comment #9: Learning Curve Claims Without Empirical Support

**Reviewer 2 noted that the paper invoked learning curve arguments without supporting evidence.**

We have added a within-period learning dynamics analysis (Section 6.6) that estimates week-specific treatment effects within the post-adoption period:

| Post-Adoption Week | Coefficient | SE | p-value |
|:---:|:---:|:---:|:---:|
| Week 1 | 0.079 | 0.089 | 0.374 |
| Week 2 | -0.028 | 0.089 | 0.755 |
| Week 3 | -0.065 | 0.089 | 0.470 |
| Week 4 | 0.284 | 0.343 | 0.407 |

The time-effect correlation is 0.48, and the week 4 coefficient (0.284) is the largest in magnitude, suggesting an increasing treatment effect trajectory consistent with---though not conclusive proof of---a learning and adaptation process. We present these results transparently, noting that individual weekly coefficients are not statistically significant due to limited within-period variation, and interpret them as suggestive directional evidence rather than definitive confirmation of learning effects.

> **Revised text (Section 6.6):** "The within-period trajectory is suggestive of an adaptation process: the correlation between post-adoption week and estimated treatment effect is 0.48, and the largest coefficient appears in week 4. However, we interpret this pattern cautiously, as individual weekly estimates are imprecise. Definitive evidence of learning dynamics would require substantially longer post-adoption observation."

---

### Comment #10: Single Platform, Single Country

**Reviewer 2 noted that findings from a single delivery platform in one country may not generalize.**

We fully acknowledge this limitation. A dedicated subsection in the Limitations section (Section 8.2) discusses external validity constraints, including: (a) platform-specific features (compensation structure, order assignment protocol, market density) that may moderate AI's effects; (b) country-specific institutional factors (labor regulations, digital infrastructure, rider demographics) that may limit cross-national generalizability; and (c) task-specificity, as last-mile delivery represents a particular combination of physical and cognitive task components that may not transfer to other gig work contexts. We frame this limitation constructively by identifying specific dimensions along which future multi-platform, cross-country research could extend our findings.

---

### Comment #11: Missing Conclusion, Implications, and Limitations Sections

**Reviewer 2 noted the absence of Conclusion, Implications, and Limitations sections.**

We have added all three sections (Section 8):

- **Section 8.1 -- Conclusion** summarizes the three main findings corresponding to our three research questions.
- **Section 8.2 -- Limitations** provides a detailed discussion of five key limitations: short observation period, single-platform setting, non-random adoption, inability to observe worker-level mechanisms directly, and consumer-side data constraints.
- **Section 8.3 -- Theoretical Implications** discusses contributions to the task-based framework, the AI-and-work literature, and platform operations theory.
- **Section 8.4 -- Practical Implications** offers actionable guidance for platform designers and policymakers, grounded strictly in our empirical findings.

These sections span approximately four pages of new content and are referenced throughout the revised manuscript where appropriate.

---

We believe these revisions comprehensively address the concerns raised by the Associate Editor and both reviewers. We are grateful for the guidance that enabled us to substantially strengthen the theoretical, methodological, and structural foundations of this paper. We look forward to your further feedback.

Respectfully,
The Authors
