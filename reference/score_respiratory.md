# Respiratory component of the SOFA score

Scores the respiratory subscale of the Sequential Organ Failure
Assessment (SOFA) from the ratio of arterial oxygen partial pressure to
fractional inspired oxygen (`PaO2/FiO2`). Sub-scores of 3 and 4 are only
assigned to mechanically ventilated patients; if `ventilated` is
supplied and `FALSE`, the score is capped at 2 (matching the original
SOFA definition).

## Usage

``` r
score_respiratory(pao2_fio2, ventilated = NULL, units = c("kPa", "mmHg"))
```

## Arguments

- pao2_fio2:

  Numeric vector of `PaO2/FiO2` ratios.

- ventilated:

  Optional logical or 0/1 numeric vector indicating mechanical
  ventilation. If `NULL` (the default), no cap is applied.

- units:

  One of `"kPa"` or `"mmHg"`. Defaults to `"kPa"` (the SI unit).
  Internally the thresholds are 100, 200, 300, 400 mmHg (~ 13.3, 26.7,
  40, 53.3 kPa).

## Value

Integer vector in `{0, 1, 2, 3, 4}` (or `NA_integer_`) of the same
length as `pao2_fio2`.

## Scoring rules

Using mmHg:

- `PaO2/FiO2 < 100` and ventilated: 4

- `PaO2/FiO2 < 200` and ventilated: 3

- `PaO2/FiO2 < 300`: 2

- `PaO2/FiO2 < 400`: 1

- `PaO2/FiO2 >= 400`: 0

## References

Vincent, J. L., et al. (1996). The SOFA (Sepsis-related Organ Failure
Assessment) score to describe organ dysfunction/failure. *Intensive Care
Medicine*, 22(7), 707-710.

## Examples

``` r
score_respiratory(c(450, 350, 250, 150, 80),
                  ventilated = c(0, 0, 1, 1, 1),
                  units = "mmHg")
#> [1] 0 1 2 3 4
```
