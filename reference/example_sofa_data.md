# Synthetic ICU example data

Returns a synthetic, longitudinal data set in the layout typical of an
ICU case-report form: one row per (subject, day) with the columns needed
by
[`calculate_sofa()`](https://ksa98.github.io/sofamatic/reference/calculate_sofa.md)
plus a few demographic / context columns.

## Usage

``` r
example_sofa_data(n_subjects = 10, days_each = 5, seed = 42)
```

## Arguments

- n_subjects:

  Number of subjects.

- days_each:

  Number of consecutive observation days per subject.

- seed:

  Optional integer seed for reproducibility (default `42`).

## Value

A data frame with `n_subjects * days_each` rows and the following
columns:

- `subject_id`:

  integer subject id

- `day`:

  0-indexed day since admission

- `age`:

  years

- `sex`:

  `"F"`/`"M"`

- `bmi`:

  kg/m^2

- `pao2_fio2`:

  kPa

- `ventilated`:

  0/1

- `platelets`:

  10^9/L

- `bilirubin`:

  umol/L

- `vasopressors`:

  0/1 flag

- `noradrenaline`:

  ug/kg/min

- `map`:

  mmHg

- `sedation`:

  0/1

- `gcs`:

  3-15 (with occasional `NA` for sedated patients)

- `creatinine`:

  umol/L

- `urine_output`:

  mL/24h

- `dialysis`:

  0/1

## Details

**The data are entirely simulated and contain no patient information.**
Distributions are loosely calibrated to be plausible on an adult ICU
service (e.g., `pao2_fio2` skewing low for ventilated patients,
occasional missing `gcs` for sedated patients, ~10 % dialysis
prevalence) but they should never be used to draw clinical conclusions.

## Examples

``` r
df <- example_sofa_data(n_subjects = 5, days_each = 4)
head(df)
#>   subject_id day age sex  bmi pao2_fio2 ventilated platelets bilirubin
#> 1          1   0  78   M 34.8      18.0          1       146         2
#> 2          1   1  78   M 34.8      32.6          1       150        36
#> 3          1   2  78   M 34.8      27.3          0       229        27
#> 4          1   3  78   M 34.8      16.4          1       106        47
#> 5          2   0  55   F 21.1      24.6          1       177        19
#> 6          2   1  55   F 21.1      29.6          1        71        46
#>   vasopressors noradrenaline  map sedation gcs creatinine urine_output dialysis
#> 1            1         0.014 68.5        0   6        152         1077        0
#> 2            0         0.000 79.6        0   6        143          868        0
#> 3            1         0.015 63.6        0  13         60         1113        0
#> 4            0         0.000 83.8        0   3         20         1389        0
#> 5            0         0.000 64.5        0  11        122          779        0
#> 6            1         0.005 79.9        1   3         89         2722        0
```
