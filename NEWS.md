# Sofamatic 0.1.0

First public release. *Sofar, so good.*

* `score_respiratory()`, `score_coagulation()`, `score_liver()`,
  `score_cardiovascular()`, `score_neurological()`, `score_renal()` —
  vectorised functions for each SOFA component, supporting both SI and
  conventional units where applicable.
* `calculate_sofa()` — aggregate the six sub-scores plus the total
  `SOFA_score` over a long-format data frame, with optional `id`/`time`
  arguments that produce per-subject `SOFA_admission` (first day) and
  `SOFA_max` (worst day).
* `example_sofa_data()` — synthetic longitudinal example for documentation
  and tests.
* Configurable handling of missing GCS values via `score_neurological()`
  and `na_strategy` in `calculate_sofa()`.
* Full testthat suite (45+ tests covering boundary thresholds and the
  special-case logic for vasoactive drugs, dialysis, and missing GCS).
