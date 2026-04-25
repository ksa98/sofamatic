# Sofamatic: Sequential Organ Failure Assessment scoring in R

Automatic SOFA scoring for R. Vectorised, dependency-light functions for
computing SOFA subscores and the total SOFA score from clinical data,
including longitudinal helpers for first-day and worst-day scoring.

## Component functions

- [`score_respiratory()`](https://ksa98.github.io/sofamatic/reference/score_respiratory.md)
  – PaO2/FiO2 with optional ventilation flag

- [`score_coagulation()`](https://ksa98.github.io/sofamatic/reference/score_coagulation.md)
  – platelets

- [`score_liver()`](https://ksa98.github.io/sofamatic/reference/score_liver.md)
  – bilirubin

- [`score_cardiovascular()`](https://ksa98.github.io/sofamatic/reference/score_cardiovascular.md)
  – MAP, vasoactive doses

- [`score_neurological()`](https://ksa98.github.io/sofamatic/reference/score_neurological.md)
  – GCS, optional sedation

- [`score_renal()`](https://ksa98.github.io/sofamatic/reference/score_renal.md)
  – creatinine, urine output, dialysis

## Aggregator

[`calculate_sofa()`](https://ksa98.github.io/sofamatic/reference/calculate_sofa.md)
takes a data frame and returns it augmented with all six subscores, the
total `SOFA_score`, and (for longitudinal data) `SOFA_admission` and
`SOFA_max` per subject.

## Citation

If you use Sofamatic in academic work, please cite the package – see
`citation("sofamatic")`.

## See also

Useful links:

- <https://github.com/ksa98/sofamatic>

- <https://ksa98.github.io/sofamatic/>

- Report bugs at <https://github.com/ksa98/sofamatic/issues>

## Author

**Maintainer**: Keano Samaritakis <do-not-contact@invalid>
([ORCID](https://orcid.org/0000-0002-6338-1918)) \[copyright holder\]
