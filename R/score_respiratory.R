#' Respiratory component of the SOFA score
#'
#' Scores the respiratory subscale of the Sequential Organ Failure Assessment
#' (SOFA) from the ratio of arterial oxygen partial pressure to fractional
#' inspired oxygen (`PaO2/FiO2`). Sub-scores of 3 and 4 are only assigned to
#' mechanically ventilated patients; if `ventilated` is supplied and `FALSE`,
#' the score is capped at 2 (matching the original SOFA definition).
#'
#' @param pao2_fio2 Numeric vector of `PaO2/FiO2` ratios.
#' @param ventilated Optional logical or 0/1 numeric vector indicating
#'   mechanical ventilation. If `NULL` (the default), no cap is applied.
#' @param units One of `"kPa"` or `"mmHg"`. Defaults to `"kPa"` (the SI
#'   unit). Internally the thresholds are 100, 200, 300, 400 mmHg
#'   (≈ 13.3, 26.7, 40, 53.3 kPa).
#'
#' @return Integer vector in `{0, 1, 2, 3, 4}` (or `NA_integer_`) of the same
#'   length as `pao2_fio2`.
#'
#' @section Scoring rules:
#' Using mmHg:
#' \itemize{
#'   \item `PaO2/FiO2 < 100` and ventilated: 4
#'   \item `PaO2/FiO2 < 200` and ventilated: 3
#'   \item `PaO2/FiO2 < 300`: 2
#'   \item `PaO2/FiO2 < 400`: 1
#'   \item `PaO2/FiO2 >= 400`: 0
#' }
#'
#' @examples
#' score_respiratory(c(450, 350, 250, 150, 80),
#'                   ventilated = c(0, 0, 1, 1, 1),
#'                   units = "mmHg")
#'
#' @references
#' Vincent, J. L., et al. (1996). The SOFA (Sepsis-related Organ Failure
#'   Assessment) score to describe organ dysfunction/failure. *Intensive Care
#'   Medicine*, 22(7), 707–710.
#'
#' @export
score_respiratory <- function(pao2_fio2,
                              ventilated = NULL,
                              units = c("kPa", "mmHg")) {
  units <- match.arg(units)
  pf <- as.numeric(pao2_fio2)

  thresholds <- if (units == "kPa") {
    c(t4 = 13.3, t3 = 26.7, t2 = 40, t1 = 53.3)
  } else {
    c(t4 = 100,  t3 = 200,  t2 = 300, t1 = 400)
  }

  out <- rep(NA_integer_, length(pf))
  out[pf >= thresholds["t1"]] <- 0L
  out[pf <  thresholds["t1"]] <- 1L
  out[pf <  thresholds["t2"]] <- 2L
  out[pf <  thresholds["t3"]] <- 3L
  out[pf <  thresholds["t4"]] <- 4L

  if (!is.null(ventilated)) {
    vent <- as.logical(ventilated)
    needs_vent <- !is.na(out) & out >= 3L & !is.na(vent) & !vent
    out[needs_vent] <- 2L
  }

  out
}
