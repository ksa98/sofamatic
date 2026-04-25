# Cardiovascular component of the SOFA score

Scores the cardiovascular subscale of the SOFA from mean arterial
pressure (MAP) and, if available, the dosing of vasoactive drugs. The
function supports two calling conventions:

## Usage

``` r
score_cardiovascular(
  map,
  vasopressors = NULL,
  dopamine = NULL,
  dobutamine = NULL,
  norepinephrine = NULL,
  epinephrine = NULL
)
```

## Arguments

- map:

  Numeric vector of mean arterial pressure in mmHg.

- vasopressors:

  Optional logical or 0/1 numeric flag indicating that any vasopressor
  was running.

- dopamine, dobutamine, norepinephrine, epinephrine:

  Optional numeric vectors of drug dose in ug/kg/min. `NULL` (default)
  means the drug was not given or the data are unavailable.

## Value

Integer vector in `{0, 1, 2, 3, 4}` (or `NA_integer_`).

## Details

1.  **Detailed dosing** – pass any subset of `dopamine`, `dobutamine`,
    `norepinephrine`, `epinephrine` as numeric vectors (in ug/kg/min).
    This follows the canonical SOFA definition (Vincent 1996) and is the
    recommended path when individual drug doses are recorded.

2.  **Simple flag + norepinephrine dose** – pass `vasopressors` (logical
    or 0/1) together with `norepinephrine` (ug/kg/min). This is
    convenient when norepinephrine is the only dose recorded numerically
    and other vasoactive use is captured by a single binary flag.

If neither vasoactive information is supplied, the score is determined
by MAP alone (0 or 1).

## Scoring rules

- 4: dopamine \> 15, or norepinephrine \> 0.1, or epinephrine \> 0.1

- 3: dopamine \> 5, or norepinephrine \> 0 (\<= 0.1), or epinephrine \>
  0 (\<= 0.1)

- 2: dopamine \> 0 (\<= 5), or any dobutamine

- 1: MAP \< 70 mmHg with no vasoactive support

- 0: MAP \>= 70 mmHg with no vasoactive support

## Examples

``` r
# detailed dosing
score_cardiovascular(map = c(80, 65, 60, 60),
                     norepinephrine = c(0, 0, 0.05, 0.2))
#> [1] 0 1 3 4

# simple-flag style: vasopressors as a binary indicator
score_cardiovascular(map = c(80, 65, 60, 60),
                     vasopressors = c(0, 0, 1, 1),
                     norepinephrine = c(0, 0, 0.05, 0.2))
#> [1] 0 1 3 4
```
