# Renal component of the SOFA score

Scores the renal subscale of the SOFA from serum creatinine and,
optionally, 24-hour urine output. When `dialysis` is supplied, any
patient receiving dialysis is assigned score 4.

## Usage

``` r
score_renal(
  creatinine,
  urine_output = NULL,
  dialysis = NULL,
  units = c("umol/L", "mg/dL")
)
```

## Arguments

- creatinine:

  Numeric vector of serum creatinine.

- urine_output:

  Optional numeric vector of 24-hour urine output in mL.

- dialysis:

  Optional logical or 0/1 vector indicating renal replacement therapy.
  Patients receiving dialysis are scored 4 regardless of creatinine and
  urine output.

- units:

  One of `"umol/L"` (default) or `"mg/dL"` for creatinine. Conversion
  factor 1 mg/dL ~ 88.4 umol/L.

## Value

Integer vector in `{0, 1, 2, 3, 4}` (or `NA_integer_`).

## Scoring rules (umol/L)

- `< 110`: 0

- `110-170`: 1

- `171-299`: 2

- `300-440`, or urine `< 500 mL/24h`: 3

- `> 440`, or urine `< 200 mL/24h`: 4

## Examples

``` r
score_renal(c(80, 130, 200, 350, 500))
#> [1] 0 1 2 3 4
score_renal(creatinine = c(80, 130, 200),
            urine_output = c(2000, 600, 150))
#> [1] 0 1 4
score_renal(creatinine = c(80, 80, 80),
            dialysis = c(0, 0, 1))
#> [1] 0 0 4
```
