# Changelog

## Sofamatic 0.1.0

First public release. *Sofar, so good.*

- [`score_respiratory()`](https://ksa98.github.io/sofamatic/reference/score_respiratory.md),
  [`score_coagulation()`](https://ksa98.github.io/sofamatic/reference/score_coagulation.md),
  [`score_liver()`](https://ksa98.github.io/sofamatic/reference/score_liver.md),
  [`score_cardiovascular()`](https://ksa98.github.io/sofamatic/reference/score_cardiovascular.md),
  [`score_neurological()`](https://ksa98.github.io/sofamatic/reference/score_neurological.md),
  [`score_renal()`](https://ksa98.github.io/sofamatic/reference/score_renal.md)
  — vectorised functions for each SOFA component, supporting both SI and
  conventional units where applicable.
- [`calculate_sofa()`](https://ksa98.github.io/sofamatic/reference/calculate_sofa.md)
  — aggregate the six sub-scores plus the total `SOFA_score` over a
  long-format data frame, with optional `id`/`time` arguments that
  produce per-subject `SOFA_admission` (first day) and `SOFA_max` (worst
  day).
- [`example_sofa_data()`](https://ksa98.github.io/sofamatic/reference/example_sofa_data.md)
  — synthetic longitudinal example for documentation and tests.
- Configurable handling of missing GCS values via
  [`score_neurological()`](https://ksa98.github.io/sofamatic/reference/score_neurological.md)
  and `na_strategy` in
  [`calculate_sofa()`](https://ksa98.github.io/sofamatic/reference/calculate_sofa.md).
- Full testthat suite (45+ tests covering boundary thresholds and the
  special-case logic for vasoactive drugs, dialysis, and missing GCS).
