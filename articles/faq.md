# Frequently asked questions

A short collection of questions that come up repeatedly. If you have one
that isn’t covered here, please open an issue at
<https://github.com/ksa98/sofamatic/issues>.

## Does this match the original Vincent 1996 SOFA?

Yes. Thresholds and tier definitions follow the original publication
(Vincent et al., 1996, *Intensive Care Medicine* 22(7), 707–710). Where
the paper specifies a half-open interval (e.g., `>= 110, <= 170` µmol/L
for renal tier 1), the implementation reproduces it exactly — including
the small consequences described in [Edge cases and
limits](https://ksa98.github.io/sofamatic/articles/edge-cases-and-limits.md).

## Is this validated for clinical use?

No. `sofamatic` is a research-grade implementation of a published
scoring rule. The scoring logic is unit-tested for boundary conditions
(`tests/testthat/`), but the package has no regulatory clearance and is
not a medical device. Clinical interpretation, validation against your
local cohort, and any downstream use are the user’s responsibility.

## Can I use it on MIMIC, eICU, or AmsterdamUMCdb?

Yes. The package does not ship with any third-party dataset, but
[`calculate_sofa()`](https://ksa98.github.io/sofamatic/reference/calculate_sofa.md)
accepts arbitrary column names so it slots into existing extracts
without renaming columns:

``` r
calculate_sofa(
  mimic_extract,
  pao2_fio2     = "pf_ratio",     units_pao2_fio2  = "mmHg",
  bilirubin     = "bilirubin_mg", units_bilirubin  = "mg/dL",
  creatinine    = "creat_mg",     units_creatinine = "mg/dL",
  noradrenaline = "norepi_dose",
  id            = "stay_id",
  time          = "icu_day"
)
```

See the [case
study](https://ksa98.github.io/sofamatic/articles/case-study-icu-cohort.md)
for a full worked example using the package’s synthetic data, which
mirrors the layout typical of those cohorts.

## What about qSOFA, mSOFA, or pediatric SOFA?

Out of scope for `sofamatic`. The package implements the canonical adult
SOFA only. Variants with different thresholds (qSOFA), reduced component
sets (mSOFA), or different age-banded normal ranges (pediatric / pSOFA)
deserve their own implementations and clinical validation; mixing them
into a single function would invite errors.

## How does the package handle multiple measurements per day?

It doesn’t aggregate for you — each row is scored independently. If your
raw data contains several measurements per patient per day, do the
aggregation upstream and decide which rule applies (worst-of-day is the
most common):

``` r
# Worst-of-day reduction before scoring
daily <- aggregate(
  cbind(pao2_fio2, platelets, bilirubin, map, gcs, creatinine) ~
    subject_id + day,
  data = raw,
  FUN  = function(x) min(x, na.rm = TRUE)   # worst MAP/GCS/PF; max for cr/bili
)
```

## Why is `SOFA_admission` constant within subject?

It’s the `SOFA_score` at the earliest `time` per `id`, broadcast back to
every row of that subject. Storing it on every row means you can compute
`delta_SOFA <- SOFA_max - SOFA_admission` without an extra join or a
[`merge()`](https://rdrr.io/r/base/merge.html). The same applies to
`SOFA_max`.

## Can I use it with tidyverse / data.table?

Yes —
[`calculate_sofa()`](https://ksa98.github.io/sofamatic/reference/calculate_sofa.md)
is just a function that takes and returns a `data.frame`, so it composes
with the native pipe and with both ecosystems:

``` r
library(dplyr)
icu |>
  calculate_sofa(id = "subject_id", time = "day") |>
  group_by(subject_id) |>
  summarise(delta = first(SOFA_max) - first(SOFA_admission))
```

``` r
library(data.table)
setDT(calculate_sofa(icu, id = "subject_id", time = "day"))[
  , .(delta = first(SOFA_max) - first(SOFA_admission)), by = subject_id]
```

## How large a dataset can it handle?

Each component function is vectorised over its input vectors, so cost
scales linearly with row count and is dominated by the underlying
arithmetic, not by R-level overhead. Million-row inputs run in a few
seconds on a laptop. For datasets that don’t fit in memory, partition
upstream and call
[`calculate_sofa()`](https://ksa98.github.io/sofamatic/reference/calculate_sofa.md)
per chunk — the function is stateless except for the optional
`id`/`time` aggregation, which you should perform on the whole-cohort
output.

## Why is `SOFA_score` non-`NA` even when most inputs are missing?

The default `na_strategy = "sum_na_zero"` treats missing sub-scores as 0
in the total. This is convenient for partially observed rows but hides
pervasive missingness. Switch to `na_strategy = "propagate"` if you’d
rather see `NA` whenever any sub-score is missing — and see [Edge cases
and
limits](https://ksa98.github.io/sofamatic/articles/edge-cases-and-limits.html#missing-sub-scores-the-silent-zero)
for a worked example and a defensive wrapper.

## Why does my non-ventilated patient still get respiratory tier 4?

Tiers 3 and 4 of the respiratory sub-score require ventilation. The
demotion to tier 2 fires only when `ventilated` is *explicitly*
`FALSE`/`0` — `NA` and `NULL` both leave the higher tier in place,
because silently demoting unknown rows would systematically under-score
patients with missing ventilation status. If your dataset encodes “no
ventilator” as `NA`, recode to `FALSE`/`0` before scoring.

## Why does a `vasopressors = TRUE` flag with no dose stay at MAP tiers?

The flag is a *companion* to a numeric norepinephrine dose, not a
substitute for it. SOFA cardiovascular tiers 2–4 are defined by specific
drug-dose thresholds; a binary “any pressors” flag does not contain
enough information to assign one. If you have only a flag and no dose,
you cannot recover tiers 3–4 from that alone — the limitation is in the
score definition, not the package.

## Where are the tests?

In `tests/testthat/`. Run them with `devtools::test()` or
[`testthat::test_local()`](https://testthat.r-lib.org/reference/test_package.html)
from the package root. Coverage is reported on
[Codecov](https://app.codecov.io/gh/ksa98/sofamatic) on every push to
`main`.

## What R versions are supported?

R \>= 4.0.0. The package depends on base R and `stats` only — there are
no other runtime dependencies.

## How do I cite Sofamatic?

``` r
citation("sofamatic")
```

The repository also includes a
[CITATION.cff](https://github.com/ksa98/sofamatic/blob/main/CITATION.cff)
file, which GitHub uses to render the *Cite this repository* button on
the project page.
