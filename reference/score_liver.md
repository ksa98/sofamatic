# Hepatic component of the SOFA score

Scores the liver subscale of the SOFA from total serum bilirubin.

## Usage

``` r
score_liver(bilirubin, units = c("umol/L", "mg/dL"))
```

## Arguments

- bilirubin:

  Numeric vector of total bilirubin.

- units:

  One of `"umol/L"` (default) or `"mg/dL"`. Conversion factor 1 mg/dL ~
  17.1 umol/L.

## Value

Integer vector in `{0, 1, 2, 3, 4}` (or `NA_integer_`).

## Scoring rules (umol/L)

- `< 20`: 0

- `>= 20, < 33`: 1

- `>= 33, < 102`: 2

- `>= 102, <= 204`: 3

- `> 204`: 4

## Examples

``` r
score_liver(c(15, 25, 50, 150, 250))
#> [1] 0 1 2 3 4
score_liver(c(0.8, 1.5, 3, 8, 14), units = "mg/dL")
#> [1] 0 1 2 3 4
```
