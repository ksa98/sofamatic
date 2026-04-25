# Introduction to Sofamatic

> *Automatic SOFA scoring for R.*

## What this package does

`sofamatic` computes the Sequential Organ Failure Assessment (SOFA)
score and its six sub-scores from clinical data. It exposes one
vectorised function per component plus a
[`calculate_sofa()`](https://ksa98.github.io/sofamatic/reference/calculate_sofa.md)
aggregator that takes a long-format data frame and returns it augmented
with all sub-scores, the total score, and (optionally) longitudinal
helpers (`SOFA_admission`, `SOFA_max`).

The thresholds follow the canonical definition (Vincent et al., 1996).
Both SI units (kPa, µmol/L) and conventional units (mmHg, mg/dL) are
supported.

``` r
library(sofamatic)
```

## Single-component scoring

Each component is a vectorised function:

``` r
score_respiratory(c(450, 350, 250, 150, 80),
                  ventilated = c(0, 0, 1, 1, 1),
                  units = "mmHg")
#> [1] 0 1 2 3 4

score_coagulation(c(180, 130, 75, 35, 12))
#> [1] 0 1 2 3 4

score_liver(c(0.8, 1.5, 3, 8, 14), units = "mg/dL")
#> [1] 0 1 2 3 4

score_cardiovascular(map = c(80, 65, 60, 60),
                     norepinephrine = c(0, 0, 0.05, 0.2))
#> [1] 0 1 3 4

score_neurological(c(15, 13, 11, 8, 4))
#> [1] 0 1 2 3 4

score_renal(creatinine = c(0.9, 1.5, 2.5, 4, 6), units = "mg/dL")
#> [1] 0 1 2 3 4
```

Use
[`?score_respiratory`](https://ksa98.github.io/sofamatic/reference/score_respiratory.md)
(etc.) to see the full thresholds and unit conventions.

## Cross-sectional aggregation

[`calculate_sofa()`](https://ksa98.github.io/sofamatic/reference/calculate_sofa.md)
accepts a data frame and column names. Defaults match the parameter
names (`pao2_fio2`, `platelets`, `bilirubin`, `map`, `gcs`,
`creatinine`, …); every column name is overridable.

``` r
df <- example_sofa_data(n_subjects = 4, days_each = 1)
calculate_sofa(df)[, c("SOFA_resp", "SOFA_coag", "SOFA_liver",
                       "SOFA_cardio", "SOFA_neuro", "SOFA_renal",
                       "SOFA_score")]
#>   SOFA_resp SOFA_coag SOFA_liver SOFA_cardio SOFA_neuro SOFA_renal SOFA_score
#> 1         2         1          1           0          3          4         11
#> 2         2         1          0           3          2          4         12
#> 3         1         4          2           3          2          0         12
#> 4         2         0          0           3          4          2         11
```

## Longitudinal data

For long-format longitudinal data (one row per subject per day), supply
`id` and `time` to also get `SOFA_admission` (first day) and `SOFA_max`
(worst day) per subject.

``` r
df  <- example_sofa_data(n_subjects = 3, days_each = 4)
out <- calculate_sofa(df, id = "subject_id", time = "day")
out[, c("subject_id", "day",
        "SOFA_score", "SOFA_admission", "SOFA_max")]
#>    subject_id day SOFA_score SOFA_admission SOFA_max
#> 1           1   0          3              3        9
#> 2           1   1          7              3        9
#> 3           1   2          5              3        9
#> 4           1   3          9              3        9
#> 5           2   0          5              5        9
#> 6           2   1          7              5        9
#> 7           2   2          8              5        9
#> 8           2   3          9              5        9
#> 9           3   0          8              8       12
#> 10          3   1          8              8       12
#> 11          3   2          9              8       12
#> 12          3   3         12              8       12
```

## Handling missing data

`calculate_sofa(na_strategy = "sum_na_zero")` (the default) treats `NA`
sub-scores as 0 in the total — convenient when only some components are
unmeasured. Use `na_strategy = "propagate"` to instead return `NA`
whenever any sub-score is missing.

For the neurological sub-score,
[`score_neurological()`](https://ksa98.github.io/sofamatic/reference/score_neurological.md)
accepts a `sedation` flag. A missing GCS in a non-sedated patient is
treated as “alert” (score 0); a missing GCS in a sedated patient is
treated as moderate impairment (score 2). This reflects the common ICU
practice in which fully responsive, non-sedated patients are often not
re-assessed, leaving the GCS field blank.

## The synthetic example dataset

[`example_sofa_data()`](https://ksa98.github.io/sofamatic/reference/example_sofa_data.md)
returns a fully synthetic, longitudinal ICU-style dataset. The data are
simulated and never describe a real patient. Distributions are loosely
calibrated to look plausible (e.g., lower PaO2/FiO2 in ventilated rows,
occasional missing GCS in sedated rows, ~10 % dialysis prevalence), but
they should never be used to draw clinical conclusions.

``` r
str(example_sofa_data(n_subjects = 2, days_each = 2))
#> 'data.frame':    4 obs. of  17 variables:
#>  $ subject_id   : int  1 1 2 2
#>  $ day          : int  0 1 0 1
#>  $ age          : num  78 78 55 55
#>  $ sex          : chr  "F" "F" "M" "M"
#>  $ bmi          : num  30.2 30.2 29 29
#>  $ pao2_fio2    : num  24.5 35.4 55.1 13.9
#>  $ ventilated   : num  1 1 0 1
#>  $ platelets    : num  229 252 137 215
#>  $ bilirubin    : num  2 5 4 2
#>  $ vasopressors : num  0 1 0 0
#>  $ noradrenaline: num  0 0.045 0 0
#>  $ map          : num  92.1 89 75.7 77.4
#>  $ sedation     : num  1 0 0 1
#>  $ gcs          : int  10 4 5 10
#>  $ creatinine   : num  112 122 88 155
#>  $ urine_output : num  1064 679 1760 1013
#>  $ dialysis     : num  1 0 0 0
```

## Units and thresholds at a glance

| Component      | Threshold variable | Standard unit   | Conventional unit |
|----------------|--------------------|-----------------|-------------------|
| Respiratory    | PaO2/FiO2          | kPa             | mmHg              |
| Coagulation    | Platelets          | 10⁹/L           | —                 |
| Liver          | Bilirubin          | µmol/L          | mg/dL             |
| Cardiovascular | MAP, vasoactives   | mmHg, µg/kg/min | —                 |
| Neurological   | GCS                | 3–15            | —                 |
| Renal          | Creatinine, urine  | µmol/L, mL/24h  | mg/dL             |

## References

Vincent, J. L., Moreno, R., Takala, J., Willatts, S., De Mendonça, A.,
Bruining, H., … Thijs, L. G. (1996). The SOFA (Sepsis-related Organ
Failure Assessment) score to describe organ dysfunction/failure.
*Intensive Care Medicine*, 22(7), 707–710.
<https://doi.org/10.1007/BF01709751>
