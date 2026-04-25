# Calculate SOFA scores for a clinical dataset

`calculate_sofa()` is the workhorse of the package. It takes a data
frame (cross-sectional or longitudinal in long format) and appends the
six SOFA subscores plus the total `SOFA_score` column. For longitudinal
data (one row per subject per day), supply `id` and optionally `time` to
also get `SOFA_admission` (first observation) and `SOFA_max` (worst
score during follow-up) per subject.

## Usage

``` r
calculate_sofa(
  data,
  pao2_fio2 = "pao2_fio2",
  ventilated = "ventilated",
  platelets = "platelets",
  bilirubin = "bilirubin",
  vasopressors = "vasopressors",
  noradrenaline = "noradrenaline",
  dopamine = NULL,
  dobutamine = NULL,
  epinephrine = NULL,
  map = "map",
  sedation = "sedation",
  gcs = "gcs",
  creatinine = "creatinine",
  urine_output = "urine_output",
  dialysis = "dialysis",
  id = NULL,
  time = NULL,
  units_pao2_fio2 = c("kPa", "mmHg"),
  units_bilirubin = c("umol/L", "mg/dL"),
  units_creatinine = c("umol/L", "mg/dL"),
  na_strategy = c("sum_na_zero", "propagate")
)
```

## Arguments

- data:

  A data frame in long format. Each row is one observation (one subject,
  one time point).

- pao2_fio2, platelets, bilirubin, map, gcs, creatinine:

  Column names (as character strings) holding the corresponding clinical
  measurements.

- ventilated, sedation, vasopressors, dialysis:

  Optional column names for binary indicators (logical or 0/1). Pass
  `NULL` to skip a variable.

- noradrenaline, dopamine, dobutamine, epinephrine:

  Optional column names for vasoactive drug doses (ug/kg/min). Pass
  `NULL` to skip a drug.

- urine_output:

  Optional column name for 24-hour urine output (mL).

- id, time:

  Optional column names for subject id and time. When both are supplied,
  the returned data frame includes `SOFA_admission` (the `SOFA_score` at
  the earliest `time` per `id`) and `SOFA_max` (the maximum `SOFA_score`
  per `id`).

- units_pao2_fio2:

  `"kPa"` or `"mmHg"`.

- units_bilirubin, units_creatinine:

  `"umol/L"` or `"mg/dL"`.

- na_strategy:

  How to aggregate the six subscores into a total. One of
  `"sum_na_zero"` (default – `NA` subscores contribute 0 to the total,
  matching `rowSums(..., na.rm = TRUE)`) or `"propagate"` (any `NA`
  subscore yields `NA` total).

## Value

A data frame: `data` augmented with columns `SOFA_resp`, `SOFA_coag`,
`SOFA_liver`, `SOFA_cardio`, `SOFA_neuro`, `SOFA_renal`, `SOFA_score`,
plus `SOFA_admission` and `SOFA_max` if `id`/`time` are supplied.

## Details

Default column names match the parameter names so a data frame with
columns `pao2_fio2`, `platelets`, `bilirubin`, `map`, `gcs`,
`creatinine`, etc. works out of the box. Override any of them for
datasets that use different naming conventions.

## Examples

``` r
df <- example_sofa_data()
out <- calculate_sofa(df, id = "subject_id", time = "day")
head(out[, c("subject_id", "day",
             "SOFA_resp", "SOFA_coag", "SOFA_liver",
             "SOFA_cardio", "SOFA_neuro", "SOFA_renal",
             "SOFA_score", "SOFA_admission", "SOFA_max")])
#>   subject_id day SOFA_resp SOFA_coag SOFA_liver SOFA_cardio SOFA_neuro
#> 1          1   0         2         1          0           1          2
#> 2          1   1         2         0          0           0          3
#> 3          1   2         2         0          1           1          3
#> 4          1   3         3         0          2           0          2
#> 5          1   4         3         0          2           3          1
#> 6          2   0         2         2          0           1          1
#>   SOFA_renal SOFA_score SOFA_admission SOFA_max
#> 1          1          7              7       13
#> 2          0          5              7       13
#> 3          2          9              7       13
#> 4          1          8              7       13
#> 5          4         13              7       13
#> 6          0          6              6       11
```
