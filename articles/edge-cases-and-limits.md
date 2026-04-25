# Edge cases and limits

`sofamatic` aims to follow the canonical SOFA definition (Vincent et
al., 1996) faithfully. A faithful implementation inherits the sharp
corners of the original: thresholds are strict on one side and inclusive
on the other, units are interchangeable but not bit-identical, and
missing data have to be interpreted somewhere. This article walks
through the cases where those choices show up — so you know what to
guard against in your own pipeline.

``` r
library(sofamatic)
```

## 1. Threshold arithmetic at the boundaries

SOFA thresholds are integers (or near-integers) in the original paper,
but real measurements are floating point. The boundaries in this package
are not symmetric — most are half-open (`>=` lower, `<` upper), but a
few are closed-closed. Two cases are worth knowing about.

### Renal creatinine has small gaps

The creatinine rules are written with both endpoints inclusive:

    < 110                       -> 0
    >= 110 & <= 170             -> 1
    >= 171 & <= 299             -> 2
    >= 300 & <= 440             -> 3
    > 440                       -> 4

That works perfectly on integers, but a creatinine value that lands
*between* tiers (e.g., 170.5 µmol/L) matches no rule and falls through
to `NA`:

``` r
score_renal(c(170, 170.5, 171, 299, 299.5, 300))
#> [1]  1 NA  2  2 NA  3
```

In real datasets this typically appears after **unit conversion from
mg/dL**, which multiplies by 88.4 and produces non-integer values:

``` r
# Two patients with creatinine values that differ by 0.01 mg/dL
score_renal(c(1.92, 1.93, 1.94), units = "mg/dL")
#> [1]  1 NA  2
```

`1.93 mg/dL × 88.4 = 170.6 µmol/L` falls in the 170↔︎171 gap and returns
`NA`. **Workaround:** round creatinine to the nearest whole µmol/L
before scoring, or work natively in µmol/L:

``` r
cr_mgdl <- c(1.92, 1.93, 1.94)
score_renal(round(cr_mgdl * 88.4), units = "umol/L")
#> [1] 1 2 2
```

### Liver bilirubin tier 3 is closed at the top

Most thresholds in the package are half-open, but the liver tier-3 upper
bound is *inclusive*:

    >= 102 & <= 204  -> 3
    > 204            -> 4

So 204 µmol/L is tier 3, 204.001 is tier 4. The same rounding awareness
applies when converting from mg/dL (× 17.1):

``` r
score_liver(c(204, 204.001))
#> [1] 3 4
score_liver(c(11.9, 12.0, 12.1), units = "mg/dL")  # 11.9 × 17.1 ≈ 203.5
#> [1] 3 4 4
```

## 2. Unit conversion can flip a tier

The respiratory rule uses **rounded** kPa thresholds (13.3, 26.7, 40,
53.3) for the canonical mmHg cut-points (100, 200, 300, 400). These
agree to within ~0.1 kPa, but a value sitting on the line in mmHg can
land on the *other* side of the line in kPa.

``` r
# 99.9 mmHg = 13.32 kPa — same physiological state, two units
score_respiratory(99.9,  ventilated = 1, units = "mmHg")
#> [1] 4
score_respiratory(13.32, ventilated = 1, units = "kPa")
#> [1] 3
```

In mmHg, 99.9 is below 100 → tier 4. In kPa, 13.32 is above 13.3 → tier
3. **Pick a unit and stick with it.** Don’t round-trip values through
`mmHg → kPa → mmHg` for scoring purposes.

## 3. The ventilation cap requires an *explicit* `FALSE`

Sub-scores 3 and 4 on the respiratory subscale are reserved for
mechanically ventilated patients. The package implements this as: “if
`ventilated` is supplied and is `FALSE`, demote any 3/4 to 2.” The
demotion fires only on an *explicit* `FALSE` — `NA` and `NULL`
ventilation both leave the high score in place.

``` r
pf <- 80   # severely hypoxic (mmHg)

# Each row uses a different ventilation signal
score_respiratory(pf, ventilated = TRUE,  units = "mmHg")  # 4 — vented
#> [1] 4
score_respiratory(pf, ventilated = FALSE, units = "mmHg")  # 2 — capped
#> [1] 2
score_respiratory(pf, ventilated = NA,    units = "mmHg")  # 4 — NOT capped
#> [1] 4
score_respiratory(pf, ventilated = NULL,  units = "mmHg")  # 4 — NOT capped
#> [1] 4
```

This is intentional — silently demoting NA-ventilation rows would mean
quietly under-scoring patients whose ventilation status simply wasn’t
recorded. But it does mean **NA in your `ventilated` column inflates the
respiratory subscore** relative to a column where missing means “no”. If
your dataset uses `NA` to mean “no ventilator”, recode to `FALSE`/`0`
first.

## 4. The vasopressor *flag* is a companion, not a substitute, for dose

[`score_cardiovascular()`](https://ksa98.github.io/sofamatic/reference/score_cardiovascular.md)
accepts two calling conventions:

- **detailed dosing** — pass `dopamine`, `dobutamine`, `norepinephrine`,
  `epinephrine` doses in µg/kg/min;
- **simple flag** — pass `vasopressors = TRUE/FALSE` together with a
  numeric `norepinephrine` dose.

The flag on its own does not escalate the score — it only modulates how
the norepinephrine dose is interpreted. A patient with
`vasopressors = 1` but no recorded dose stays at the MAP-only tiers (0
or 1):

``` r
# Three patients with hypotension on pressors but no numeric dose
score_cardiovascular(map = c(60, 60, 60),
                     vasopressors = c(1, 1, 1))
#> [1] 1 1 1
```

To get tier 3 or 4 you need an actual dose:

``` r
score_cardiovascular(map = c(60, 60, 60),
                     vasopressors   = c(1, 1, 1),
                     norepinephrine = c(0.05, 0.15, 0.30))
#> [1] 3 4 4
```

If your dataset only has a binary “any pressors” flag and no doses,
**you cannot recover tiers 3–4 from that alone.** That’s not a package
limitation — it’s a SOFA limitation. Decide explicitly whether to record
a default dose, treat such rows as tier 2, or leave them at MAP tiers
and document the choice.

## 5. Missing sub-scores: the silent zero

[`calculate_sofa()`](https://ksa98.github.io/sofamatic/reference/calculate_sofa.md)
aggregates the six sub-scores into a total. The default
`na_strategy = "sum_na_zero"` treats missing components as 0, so the
total is `sum(non-missing parts)`. This is convenient when only one
variable is unmeasured — but it can hide pervasive missingness:

``` r
# A "patient" with only platelets recorded
sparse <- data.frame(
  pao2_fio2  = NA_real_,
  ventilated = NA,
  platelets  = 30,           # tier 3
  bilirubin  = NA_real_,
  vasopressors = NA,
  noradrenaline = NA_real_,
  map        = NA_real_,
  sedation   = NA,
  gcs        = NA_real_,
  creatinine = NA_real_,
  urine_output = NA_real_,
  dialysis   = NA
)

calculate_sofa(sparse)$SOFA_score          # default: 3 (looks low)
#> [1] 3
calculate_sofa(sparse,
               na_strategy = "propagate")$SOFA_score   # honest: NA
#> [1] NA
```

The default makes sense for *partially* observed rows; **for sparsely
observed rows it is misleading.** Two defenses:

1.  Track per-row coverage explicitly and reject rows below a threshold.
2.  Use `na_strategy = "propagate"` when you’d rather see `NA` than a
    spuriously low total.

``` r
sub <- c("SOFA_resp", "SOFA_coag", "SOFA_liver",
         "SOFA_cardio", "SOFA_neuro", "SOFA_renal")

scored <- calculate_sofa(sparse)
n_observed <- rowSums(!is.na(scored[, sub]))
data.frame(SOFA_score = scored$SOFA_score,
           n_observed = n_observed)
#>   SOFA_score n_observed
#> 1          3          1
```

## 6. Out-of-range GCS becomes `NA`, not an error

The neurological rule covers GCS 3–15 (the clinical range), with `< 6`
as tier 4 and `== 15` as tier 0. Values *outside* the clinical range
(typos, decimals, miscoded zeros) match no rule and silently return
`NA`:

``` r
# 15 is correct; 115 is a typo; 0 is a miscoded missing
score_neurological(c(15, 115, 0, 7.5, NA))
#> [1]  0 NA  4  3 NA
```

Note that GCS = 0 *does* match `< 6` and so scores tier 4 — there’s no
floor check. A real-world failure mode: a CSV exporter writes “0” for
“not assessed” → every such row becomes a max-severity neurological
score. **Validate GCS to the 3–15 range before scoring**, and decide
explicitly whether out-of-range values should be `NA`, an error, or
clamped.

``` r
clean_gcs <- function(x) {
  x <- suppressWarnings(as.numeric(x))
  x[x < 3 | x > 15] <- NA
  x
}

score_neurological(clean_gcs(c(15, 115, 0, 7.5, NA)))
#> [1]  0 NA NA  3 NA
```

## 7. `SOFA_max` on a fully-NA trajectory

`SOFA_max` is computed with `max(..., na.rm = TRUE)`. If a subject has
*every* `SOFA_score` value missing — only possible under
`na_strategy = "propagate"` plus pervasive missingness — base R’s
[`max()`](https://rdrr.io/r/base/Extremes.html) returns `-Inf` with a
warning:

``` r
# A subject with no measurements anywhere on either day
ghost <- data.frame(
  subject_id   = c(1, 1),
  day          = c(0, 1),
  pao2_fio2    = NA_real_, ventilated   = NA,
  platelets    = NA_real_, bilirubin    = NA_real_,
  vasopressors = NA,       noradrenaline = NA_real_,
  map          = NA_real_, sedation     = NA,
  gcs          = NA_real_,
  creatinine   = NA_real_, urine_output = NA_real_, dialysis = NA
)

suppressWarnings(
  calculate_sofa(ghost,
                 id   = "subject_id",
                 time = "day",
                 na_strategy = "propagate")
)[, c("subject_id", "day", "SOFA_score", "SOFA_admission", "SOFA_max")]
#>   subject_id day SOFA_score SOFA_admission SOFA_max
#> 1          1   0         NA             NA     -Inf
#> 2          1   1         NA             NA     -Inf
```

The `-Inf` is mathematically correct (“max of nothing”) but rarely what
you want in a downstream analysis. Filter such subjects out *before*
calling
[`calculate_sofa()`](https://ksa98.github.io/sofamatic/reference/calculate_sofa.md),
or post-process `SOFA_max` to `NA` where it equals `-Inf`.

## A defensive scoring wrapper

Putting the lessons together, here’s a small wrapper that several teams
have found useful:

``` r
score_with_guards <- function(df, ...,
                              gcs_col       = "gcs",
                              vent_col      = "ventilated",
                              min_observed  = 4) {
  # 1. Range-check GCS — typos/zeros become NA, not tier 4
  if (gcs_col %in% names(df)) {
    g <- suppressWarnings(as.numeric(df[[gcs_col]]))
    g[g < 3 | g > 15] <- NA
    df[[gcs_col]] <- g
  }
  # 2. NA ventilation -> FALSE so the cap fires conservatively
  if (vent_col %in% names(df)) {
    v <- df[[vent_col]]
    v[is.na(v)] <- 0
    df[[vent_col]] <- v
  }
  # 3. Score with propagate so missingness is visible
  out <- calculate_sofa(df, ..., na_strategy = "propagate")
  # 4. Compute coverage and clear scores below the threshold
  sub <- c("SOFA_resp", "SOFA_coag", "SOFA_liver",
           "SOFA_cardio", "SOFA_neuro", "SOFA_renal")
  n_obs <- rowSums(!is.na(out[, sub]))
  out$SOFA_score[n_obs < min_observed] <- NA
  out$n_observed <- n_obs
  out
}
```

It is deliberately small — the point is not to wrap the package, but to
show that each gotcha above is one or two lines to defend against once
you know it exists.

## References

Vincent, J. L., Moreno, R., Takala, J., Willatts, S., De Mendonça, A.,
Bruining, H., … Thijs, L. G. (1996). The SOFA (Sepsis-related Organ
Failure Assessment) score to describe organ dysfunction/failure.
*Intensive Care Medicine*, 22(7), 707–710.
<https://doi.org/10.1007/BF01709751>
