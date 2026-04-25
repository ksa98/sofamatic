# Neurological component of the SOFA score

Scores the neurological subscale of the SOFA from the Glasgow Coma Scale
(GCS). When `sedation` is supplied, a missing GCS in a sedated patient
is interpreted as moderate impairment (score 2), whereas a missing GCS
in a non-sedated patient is treated as the best clinical state (score
0). This reflects the common ICU practice in which a fully responsive,
non-sedated patient is often not re-assessed and so the GCS field is
left blank.

## Usage

``` r
score_neurological(gcs, sedation = NULL, na_strategy = c("na", "zero"))
```

## Arguments

- gcs:

  Integer or numeric vector of GCS values (3-15).

- sedation:

  Optional logical or 0/1 vector indicating whether the patient was
  sedated at the time of assessment. When `NULL`, missing GCS values
  produce `NA_integer_` scores.

- na_strategy:

  How to handle `NA` GCS when `sedation` is `NULL`. One of `"na"`
  (default – return `NA_integer_`) or `"zero"` (treat missing GCS as the
  best state, score 0).

## Value

Integer vector in `{0, 1, 2, 3, 4}` (or `NA_integer_`).

## Scoring rules

- GCS 15: 0

- GCS 13-14: 1

- GCS 10-12: 2

- GCS 6-9: 3

- GCS \< 6: 4

## Examples

``` r
score_neurological(c(15, 13, 11, 8, 4, NA))
#> [1]  0  1  2  3  4 NA
score_neurological(c(15, 13, NA, NA),
                   sedation = c(0, 0, 1, 0))
#> [1] 0 1 2 0
```
