#' Cardiovascular component of the SOFA score
#'
#' Scores the cardiovascular subscale of the SOFA from mean arterial pressure
#' (MAP) and, if available, the dosing of vasoactive drugs. The function
#' supports two calling conventions:
#'
#' 1. **Detailed dosing** -- pass any subset of `dopamine`, `dobutamine`,
#'    `norepinephrine`, `epinephrine` as numeric vectors (in ug/kg/min). This
#'    follows the canonical SOFA definition (Vincent 1996) and is the
#'    recommended path when individual drug doses are recorded.
#' 2. **Simple flag + norepinephrine dose** -- pass `vasopressors` (logical
#'    or 0/1) together with `norepinephrine` (ug/kg/min). This is convenient
#'    when norepinephrine is the only dose recorded numerically and other
#'    vasoactive use is captured by a single binary flag.
#'
#' If neither vasoactive information is supplied, the score is determined by
#' MAP alone (0 or 1).
#'
#' @param map Numeric vector of mean arterial pressure in mmHg.
#' @param vasopressors Optional logical or 0/1 numeric flag indicating that
#'   any vasopressor was running.
#' @param dopamine,dobutamine,norepinephrine,epinephrine Optional numeric
#'   vectors of drug dose in ug/kg/min. `NULL` (default) means the drug was
#'   not given or the data are unavailable.
#'
#' @return Integer vector in `{0, 1, 2, 3, 4}` (or `NA_integer_`).
#'
#' @section Scoring rules:
#' \itemize{
#'   \item 4: dopamine > 15, or norepinephrine > 0.1, or epinephrine > 0.1
#'   \item 3: dopamine > 5, or norepinephrine > 0 (<= 0.1), or epinephrine > 0 (<= 0.1)
#'   \item 2: dopamine > 0 (<= 5), or any dobutamine
#'   \item 1: MAP < 70 mmHg with no vasoactive support
#'   \item 0: MAP >= 70 mmHg with no vasoactive support
#' }
#'
#' @examples
#' # detailed dosing
#' score_cardiovascular(map = c(80, 65, 60, 60),
#'                      norepinephrine = c(0, 0, 0.05, 0.2))
#'
#' # simple-flag style: vasopressors as a binary indicator
#' score_cardiovascular(map = c(80, 65, 60, 60),
#'                      vasopressors = c(0, 0, 1, 1),
#'                      norepinephrine = c(0, 0, 0.05, 0.2))
#'
#' @export
score_cardiovascular <- function(map,
                                 vasopressors  = NULL,
                                 dopamine      = NULL,
                                 dobutamine    = NULL,
                                 norepinephrine = NULL,
                                 epinephrine   = NULL) {
  m  <- as.numeric(map)
  n  <- length(m)

  zeros_for <- function(x) {
    if (is.null(x)) rep(0, n) else {
      v <- suppressWarnings(as.numeric(x))
      ifelse(is.na(v), 0, v)
    }
  }
  vp_flag <- if (is.null(vasopressors)) {
    rep(FALSE, n)
  } else {
    fl <- suppressWarnings(as.logical(vasopressors))
    ifelse(is.na(fl), FALSE, fl)
  }

  dop <- zeros_for(dopamine)
  dob <- zeros_for(dobutamine)
  ne  <- zeros_for(norepinephrine)
  ep  <- zeros_for(epinephrine)

  out <- rep(NA_integer_, n)

  # Layer the rules from least to most severe so higher tiers overwrite.
  out[!is.na(m) & m >= 70] <- 0L
  out[!is.na(m) & m <  70] <- 1L

  tier2 <- (dop > 0 & dop <= 5) | (dob > 0)
  out[tier2] <- pmax(out[tier2], 2L, na.rm = TRUE)

  tier3 <- (dop > 5 & dop <= 15) |
           (ne  > 0 & ne <= 0.1) |
           (ep  > 0 & ep <= 0.1) |
           (vp_flag & ne > 0 & ne <= 0.1)
  out[tier3] <- pmax(out[tier3], 3L, na.rm = TRUE)

  tier4 <- (dop > 15) | (ne > 0.1) | (ep > 0.1) |
           (vp_flag & ne > 0.1)
  out[tier4] <- pmax(out[tier4], 4L, na.rm = TRUE)

  out
}
