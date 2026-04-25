#' Neurological component of the SOFA score
#'
#' Scores the neurological subscale of the SOFA from the Glasgow Coma Scale
#' (GCS). When `sedation` is supplied, a missing GCS in a sedated patient is
#' interpreted as moderate impairment (score 2), whereas a missing GCS in a
#' non-sedated patient is treated as the best clinical state (score 0).
#' This reflects the common ICU practice in which a fully responsive,
#' non-sedated patient is often not re-assessed and so the GCS field is
#' left blank.
#'
#' @param gcs Integer or numeric vector of GCS values (3–15).
#' @param sedation Optional logical or 0/1 vector indicating whether the
#'   patient was sedated at the time of assessment. When `NULL`, missing GCS
#'   values produce `NA_integer_` scores.
#' @param na_strategy How to handle `NA` GCS when `sedation` is `NULL`. One
#'   of `"na"` (default — return `NA_integer_`) or `"zero"` (treat missing
#'   GCS as the best state, score 0).
#'
#' @return Integer vector in `{0, 1, 2, 3, 4}` (or `NA_integer_`).
#'
#' @section Scoring rules:
#' \itemize{
#'   \item GCS 15:        0
#'   \item GCS 13–14:     1
#'   \item GCS 10–12:     2
#'   \item GCS  6–9:      3
#'   \item GCS  < 6:      4
#' }
#'
#' @examples
#' score_neurological(c(15, 13, 11, 8, 4, NA))
#' score_neurological(c(15, 13, NA, NA),
#'                    sedation = c(0, 0, 1, 0))
#'
#' @export
score_neurological <- function(gcs,
                               sedation    = NULL,
                               na_strategy = c("na", "zero")) {
  na_strategy <- match.arg(na_strategy)
  g <- suppressWarnings(as.numeric(gcs))

  out <- rep(NA_integer_, length(g))
  out[g == 15]            <- 0L
  out[g >= 13 & g <= 14]  <- 1L
  out[g >= 10 & g <= 12]  <- 2L
  out[g >=  6 & g <=  9]  <- 3L
  out[g <   6]            <- 4L

  if (is.null(sedation)) {
    if (na_strategy == "zero") out[is.na(g)] <- 0L
    return(out)
  }

  sed <- suppressWarnings(as.logical(sedation))
  out[is.na(g) & !is.na(sed) & !sed] <- 0L
  out[is.na(g) & !is.na(sed) &  sed] <- 2L
  out
}
