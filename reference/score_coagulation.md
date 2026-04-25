# Coagulation component of the SOFA score

Scores the coagulation subscale of the SOFA from the platelet count.

## Usage

``` r
score_coagulation(platelets)
```

## Arguments

- platelets:

  Numeric vector of platelet counts in `10^9 / L` (equivalent to
  `1000 / mm^3`).

## Value

Integer vector in `{0, 1, 2, 3, 4}` (or `NA_integer_`).

## Scoring rules

- `>= 150`: 0

- `< 150`: 1

- `< 100`: 2

- `< 50`: 3

- `< 20`: 4

## Examples

``` r
score_coagulation(c(180, 130, 75, 35, 12, NA))
#> [1]  0  1  2  3  4 NA
```
