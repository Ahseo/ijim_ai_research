# IJIM Revision Workspace

Revision workspace for the IJIM manuscript:

`Does AI Benefit All Platform Stakeholders? Evidence from Algorithmic Task Assignment in Food Delivery`

This repository currently contains:

- the **original manuscript** in `manuscript/Algorithmic task assignment_manuscript_final.docx`
- reviewer comments and revision planning documents in `docs/`
- reproducible R code in `code/`
- generated tables, figures, and interpretation notes in `output/`
- a draft response letter in `manuscript/response-letter.md`

Important status note:

- The `.docx` manuscript is still the **original pre-revision version**.
- The current revision evidence lives in `docs/`, `output/`, and `manuscript/response-letter.md`.
- Do not assume the manuscript already reflects the revision package.

## Current Snapshot

- Main analytic sample: `936` riders, `33,896` rider-days
- Matched sample: `372` riders, `10,121` rider-days
- Active Busan benchmark in study window: `1,085` riders, `35,410` rider-days
- Observation window used in the current core analysis: `2020-09-26` to `2020-11-25`
- Busan Dec-Feb extension data is **not yet integrated**

## What Is Ready

The following analyses are already implemented and have output files:

- Event-study: `code/02_event_study.R`
- Extended event-study: `code/02_event_study_extended.R`
- Oster bounds: `code/03_oster_bounds.R`
- Dose-response: `code/04_dose_response.R`
- Stable workers: `code/05_stable_workers.R`
- Inequality metrics: `code/06_inequality.R`
- Learning dynamics: `code/07_learning_dynamics.R`
- Worker-customer linkage: `code/08_worker_customer_linkage.R`
- Submission diagnostics: representativeness + precision: `code/09_submission_diagnostics.R`

## Recommended Reading Order

If you want the shortest path to the current revision state:

1. `docs/21-submission-readiness-check.md`
2. `docs/20-revision-guide.md`
3. `manuscript/response-letter.md`
4. `docs/22-reference-audit.md`
5. `output/interpretation/`

If you want the full planning history:

1. `docs/00-situation-overview.md`
2. `docs/01-convergence-map.md`
3. `docs/03-revision-roadmap.md`
4. `docs/09-paper-architecture.md`
5. `docs/10-execution-plan.md`

## Key Files

### Manuscript and review

- `manuscript/Algorithmic task assignment_manuscript_final.docx`
  - original manuscript, not yet revised
- `manuscript/review.docx`
  - editor + reviewer comments
- `manuscript/response-letter.md`
  - revision response letter draft aligned to the current evidence package

### Revision control documents

- `docs/20-revision-guide.md`
  - section-by-section revision guide
- `docs/21-submission-readiness-check.md`
  - final keep/change/avoid checklist
- `docs/22-reference-audit.md`
  - bibliography and citation alignment audit
- `docs/11-fact-check.md`
  - citation-level fact-check notes
- `docs/12-new-references.md`
  - candidate new references for the revised manuscript

### Evidence outputs

- `output/interpretation/01-event-study.md`
- `output/interpretation/02-oster-bounds.md`
- `output/interpretation/03-dose-response.md`
- `output/interpretation/04-stable-workers.md`
- `output/interpretation/05-inequality.md`
- `output/interpretation/06-learning-dynamics.md`
- `output/interpretation/07-worker-customer-linkage.md`
- `output/interpretation/08-submission-diagnostics.md`

### Figures most likely to go into the revision

- `output/figures/event_study_productivity.png`
- `output/figures/dose_response.png`
- `output/figures/inequality_density.png`
- `output/figures/worker_customer_linkage.png`
- `output/figures/sample_representativeness.png`

## Current Evidence Summary

### Identification and robustness

- Event-study pre-trends: `F = 1.41`, `p = 0.229`
- Oster bounds: `delta* = -1.249`, robust by the usual `|delta*| > 1` rule
- Stable workers: `691` of `790` riders observed in both periods satisfy the stability rule
- Dose-response: non-monotonic, so useful as a supplementary diagnostic only

### Distributional effects

- Gini: `0.181 -> 0.152`
- Theil: `0.128 -> 0.055`
- Interpretation: productivity distribution compresses after adoption

### Worker-customer linkage

- AI adoption does **not** produce a significant average customer waiting-time reduction in the matched DID table
- But more productive rider-days are associated with shorter customer waiting times
- This supports a **linkage** claim, not a formal mediation claim

### Representativeness and precision

- Analytic full sample closely matches all active Busan riders on:
  - orders/hour
  - daily orders
  - daily labor hours
  - daily fee
- Design-based precision benchmark:
  - productivity MDE: `0.212` orders/hour
  - waiting-time MDE: `0.461` minutes

## Claims To Keep vs Avoid

### Safe to use in the revision

- `skill -> proficiency`
- AI vs conventional dispatch distinction
- parallel trends support
- Oster-based robustness
- inequality compression
- strongest gains among medium-proficiency riders
- customer results are conditional on customers served by treated riders
- worker-customer linkage exists, but is not formally mediated
- analytic full sample is broadly representative of active Busan riders

### Avoid or weaken

- formal mediation claims
- customer fixed effects / weather controls unless newly added later
- platform-wide consumer welfare claims
- "single-order waiting time improved" as a headline result
- "AI promotes social equality"
- "low-proficiency workers benefited the most" as a blanket statement

## Data Files

### Required current data

- `data/riders_full.csv`
  - Busan source data used for the main one-month pre/post analysis
- `data/new_data.csv`
  - additional source data used for the extended event-study
- `data/rider_info.csv`
  - rider-level metadata used in preprocessing

### Not yet integrated

- `recommendation_data_busan_exclusive_dec_feb.csv`
  - Busan Dec-Feb extension file
  - treat any claims that require longer post-period coverage as pending until this file is added

## Data Processing

`data/processed/` is a reproducible local build artifact generated from the raw data in `data/`.

- It is **not** source data.
- It should be recreated locally before running downstream analysis scripts.
- It is excluded from Git because several generated files exceed GitHub's size limits.

### Default preprocessing command

```bash
Rscript code/00_data_preparation.R
```

This command rebuilds the full analysis inputs used by the current workflow:

- `data/processed/data_day_full.csv`
- `data/processed/data_day_matched.csv`
- `data/processed/data_shift_full.csv`
- `data/processed/data_shift_matched.csv`
- `data/processed/orders_matched.csv`
- `data/processed/orders_busan_extended.csv`
- `data/processed/matched_riders.csv`
- `data/processed/pre_matching_vars.csv`
- `data/processed/proficiency.csv`

### Alternate preprocessing path

`code/00_data_preparation_v2.R` exists as an alternate preprocessing script. Use it only when you intentionally want the earlier merged-data path with `riders_full.csv` and `new_data.csv`. The current regenerated `data/processed/` directory was rebuilt with:

```bash
Rscript code/00_data_preparation.R
```

### Practical rule before analysis

Before running `code/01_reproduce_results.R` through `code/09_submission_diagnostics.R`, confirm:

1. `data/riders_full.csv` exists
2. `data/rider_info.csv` exists
3. `data/new_data.csv` exists if you plan to run the extended event-study
4. `Rscript code/00_data_preparation.R` has completed successfully

## Reproducibility

### R packages

```r
install.packages(c(
  "data.table",
  "dplyr",
  "fixest",
  "lfe",
  "MatchIt",
  "sensemakr",
  "ggplot2",
  "cowplot",
  "lubridate"
))
```

### Suggested run order

```bash
Rscript code/00_data_preparation.R
Rscript code/01_reproduce_results.R
Rscript code/02_event_study.R
Rscript code/03_oster_bounds.R
Rscript code/04_dose_response.R
Rscript code/05_stable_workers.R
Rscript code/06_inequality.R
Rscript code/07_learning_dynamics.R
Rscript code/08_worker_customer_linkage.R
Rscript code/09_submission_diagnostics.R
```

## Repository Layout

```text
ijim_ai_research/
├── manuscript/
│   ├── Algorithmic task assignment_manuscript_final.docx
│   ├── review.docx
│   └── response-letter.md
├── code/
├── data/
│   └── processed/
├── output/
│   ├── figures/
│   ├── interpretation/
│   └── tables/
└── docs/
```

## Submission Guidance

Before touching the manuscript `.docx`, read:

1. `docs/21-submission-readiness-check.md`
2. `docs/22-reference-audit.md`
3. `manuscript/response-letter.md`

That sequence reflects the current best-available evidence and the known reference/citation corrections.
