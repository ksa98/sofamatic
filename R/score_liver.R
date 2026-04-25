#' Hepatic component of the SOFA score
#'
#' Scores the liver subscale of the SOFA from total serum bilirubin.
#'
#' @param bilirubin Numeric vector of total bilirubin.
#' @param units One of `"umol/L"` (default) or `"mg/dL"`. Conversion factor
#'   1 mg/dL ~ 17.1 umol/L.
#'
#' @return Integer vector in `{0, 1, 2, 3, 4}` (or `NA_integer_`).
#'
#' @section Scoring rules (umol/L):
#' \itemize{
#'   \item `< 20`:        0
#'   \item `>= 20, < 33`: 1
#'   \item `>= 33, < 102`: 2
#'   \item `>= 102, <= 204`: 3
#'   \item `> 204`:       4
#' }
#'
#' @examples
#' score_liver(c(15, 25, 50, 150, 250))
#' score_liver(c(0.8, 1.5, 3, 8, 14), units = "mg/dL")
#'
#' @export
score_liver <- function(bilirubin, units = c("umol/L", "mg/dL")) {
  units <- match.arg(units)
  bil <- as.numeric(bilirubin)
  if (units == "mg/dL") bil <- bil * 17.1

  out <- rep(NA_integer_, length(bil))
  out[bil <   20]                 <- 0L
  out[bil >=  20 & bil <  33]     <- 1L
  out[bil >=  33 & bil < 102]     <- 2L
  out[bil >= 102 & bil <= 204]    <- 3L
  out[bil >  204]                 <- 4L
  out
}
