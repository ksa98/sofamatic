#' Coagulation component of the SOFA score
#'
#' Scores the coagulation subscale of the SOFA from the platelet count.
#'
#' @param platelets Numeric vector of platelet counts in `10^9 / L`
#'   (equivalent to `1000 / mm^3`).
#'
#' @return Integer vector in `{0, 1, 2, 3, 4}` (or `NA_integer_`).
#'
#' @section Scoring rules:
#' \itemize{
#'   \item `>= 150`: 0
#'   \item `< 150`:  1
#'   \item `< 100`:  2
#'   \item `<  50`:  3
#'   \item `<  20`:  4
#' }
#'
#' @examples
#' score_coagulation(c(180, 130, 75, 35, 12, NA))
#'
#' @export
score_coagulation <- function(platelets) {
  pl <- as.numeric(platelets)
  out <- rep(NA_integer_, length(pl))
  out[pl >= 150] <- 0L
  out[pl <  150] <- 1L
  out[pl <  100] <- 2L
  out[pl <   50] <- 3L
  out[pl <   20] <- 4L
  out
}
