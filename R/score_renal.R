#' Renal component of the SOFA score
#'
#' Scores the renal subscale of the SOFA from serum creatinine and, optionally,
#' 24-hour urine output. When `dialysis` is supplied, any patient receiving
#' dialysis is assigned score 4.
#'
#' @param creatinine Numeric vector of serum creatinine.
#' @param urine_output Optional numeric vector of 24-hour urine output in mL.
#' @param dialysis Optional logical or 0/1 vector indicating renal replacement
#'   therapy. Patients receiving dialysis are scored 4 regardless of
#'   creatinine and urine output.
#' @param units One of `"umol/L"` (default) or `"mg/dL"` for creatinine.
#'   Conversion factor 1 mg/dL ≈ 88.4 µmol/L.
#'
#' @return Integer vector in `{0, 1, 2, 3, 4}` (or `NA_integer_`).
#'
#' @section Scoring rules (µmol/L):
#' \itemize{
#'   \item `< 110`:                          0
#'   \item `110–170`:                        1
#'   \item `171–299`:                        2
#'   \item `300–440`, or urine `< 500 mL/24h`: 3
#'   \item `> 440`,   or urine `< 200 mL/24h`: 4
#' }
#'
#' @examples
#' score_renal(c(80, 130, 200, 350, 500))
#' score_renal(creatinine = c(80, 130, 200),
#'             urine_output = c(2000, 600, 150))
#' score_renal(creatinine = c(80, 80, 80),
#'             dialysis = c(0, 0, 1))
#'
#' @export
score_renal <- function(creatinine,
                        urine_output = NULL,
                        dialysis     = NULL,
                        units        = c("umol/L", "mg/dL")) {
  units <- match.arg(units)
  cr <- as.numeric(creatinine)
  if (units == "mg/dL") cr <- cr * 88.4

  out <- rep(NA_integer_, length(cr))
  out[cr <  110]                <- 0L
  out[cr >= 110 & cr <= 170]    <- 1L
  out[cr >= 171 & cr <= 299]    <- 2L
  out[cr >= 300 & cr <= 440]    <- 3L
  out[cr >  440]                <- 4L

  if (!is.null(urine_output)) {
    uo <- as.numeric(urine_output)
    tier3 <- !is.na(uo) & uo < 500 & uo >= 200
    tier4 <- !is.na(uo) & uo < 200
    out[tier3] <- pmax(out[tier3], 3L, na.rm = TRUE)
    out[tier4] <- pmax(out[tier4], 4L, na.rm = TRUE)
  }

  if (!is.null(dialysis)) {
    dz <- suppressWarnings(as.logical(dialysis))
    out[!is.na(dz) & dz] <- 4L
  }

  out
}
