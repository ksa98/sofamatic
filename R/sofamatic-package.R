#' Sofamatic: Sequential Organ Failure Assessment scoring in R
#'
#' Automatic SOFA scoring for R. Vectorised, dependency-light functions for
#' computing SOFA subscores and the total SOFA score from clinical data,
#' including longitudinal helpers for first-day and worst-day scoring.
#'
#' @section Component functions:
#' \itemize{
#'   \item [score_respiratory()]    — PaO2/FiO2 with optional ventilation flag
#'   \item [score_coagulation()]    — platelets
#'   \item [score_liver()]          — bilirubin
#'   \item [score_cardiovascular()] — MAP, vasoactive doses
#'   \item [score_neurological()]   — GCS, optional sedation
#'   \item [score_renal()]          — creatinine, urine output, dialysis
#' }
#'
#' @section Aggregator:
#' [calculate_sofa()] takes a data frame and returns it augmented with all
#' six subscores, the total `SOFA_score`, and (for longitudinal data)
#' `SOFA_admission` and `SOFA_max` per subject.
#'
#' @section Citation:
#' If you use Sofamatic in academic work, please cite the package — see
#' `citation("sofamatic")`.
#'
#' @keywords internal
"_PACKAGE"
