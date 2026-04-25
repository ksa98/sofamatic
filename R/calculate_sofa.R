#' Calculate SOFA scores for a clinical dataset
#'
#' `calculate_sofa()` is the workhorse of the package. It takes a data frame
#' (cross-sectional or longitudinal in long format) and appends the six SOFA
#' subscores plus the total `SOFA_score` column. For longitudinal data
#' (one row per subject per day), supply `id` and optionally `time` to also
#' get `SOFA_admission` (first observation) and `SOFA_max` (worst score
#' during follow-up) per subject.
#'
#' Default column names match the parameter names so a data frame with
#' columns `pao2_fio2`, `platelets`, `bilirubin`, `map`, `gcs`, `creatinine`,
#' etc. works out of the box. Override any of them for datasets that use
#' different naming conventions.
#'
#' @param data A data frame in long format. Each row is one observation
#'   (one subject, one time point).
#' @param pao2_fio2,platelets,bilirubin,map,gcs,creatinine Column names (as
#'   character strings) holding the corresponding clinical measurements.
#' @param ventilated,sedation,vasopressors,dialysis Optional column names
#'   for binary indicators (logical or 0/1). Pass `NULL` to skip a variable.
#' @param noradrenaline,dopamine,dobutamine,epinephrine Optional column names
#'   for vasoactive drug doses (µg/kg/min). Pass `NULL` to skip a drug.
#' @param urine_output Optional column name for 24-hour urine output (mL).
#' @param id,time Optional column names for subject id and time. When both
#'   are supplied, the returned data frame includes `SOFA_admission` (the
#'   `SOFA_score` at the earliest `time` per `id`) and `SOFA_max` (the maximum
#'   `SOFA_score` per `id`).
#' @param units_pao2_fio2 `"kPa"` or `"mmHg"`.
#' @param units_bilirubin,units_creatinine `"umol/L"` or `"mg/dL"`.
#' @param na_strategy How to aggregate the six subscores into a total. One of
#'   `"sum_na_zero"` (default — `NA` subscores contribute 0 to the total,
#'   matching `rowSums(..., na.rm = TRUE)`) or `"propagate"` (any `NA`
#'   subscore yields `NA` total).
#'
#' @return A data frame: `data` augmented with columns `SOFA_resp`,
#'   `SOFA_coag`, `SOFA_liver`, `SOFA_cardio`, `SOFA_neuro`, `SOFA_renal`,
#'   `SOFA_score`, plus `SOFA_admission` and `SOFA_max` if `id`/`time` are
#'   supplied.
#'
#' @examples
#' df <- example_sofa_data()
#' out <- calculate_sofa(df, id = "subject_id", time = "day")
#' head(out[, c("subject_id", "day",
#'              "SOFA_resp", "SOFA_coag", "SOFA_liver",
#'              "SOFA_cardio", "SOFA_neuro", "SOFA_renal",
#'              "SOFA_score", "SOFA_admission", "SOFA_max")])
#'
#' @export
calculate_sofa <- function(data,
                           pao2_fio2     = "pao2_fio2",
                           ventilated    = "ventilated",
                           platelets     = "platelets",
                           bilirubin     = "bilirubin",
                           vasopressors  = "vasopressors",
                           noradrenaline = "noradrenaline",
                           dopamine      = NULL,
                           dobutamine    = NULL,
                           epinephrine   = NULL,
                           map           = "map",
                           sedation      = "sedation",
                           gcs           = "gcs",
                           creatinine    = "creatinine",
                           urine_output  = "urine_output",
                           dialysis      = "dialysis",
                           id            = NULL,
                           time          = NULL,
                           units_pao2_fio2  = c("kPa", "mmHg"),
                           units_bilirubin  = c("umol/L", "mg/dL"),
                           units_creatinine = c("umol/L", "mg/dL"),
                           na_strategy   = c("sum_na_zero", "propagate")) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  na_strategy <- match.arg(na_strategy)

  pull <- function(col) {
    if (is.null(col)) return(NULL)
    if (!col %in% names(data)) {
      stop(sprintf("Column '%s' not found in `data`.", col), call. = FALSE)
    }
    data[[col]]
  }

  out <- data
  out[["SOFA_resp"]]   <- score_respiratory(pull(pao2_fio2),
                                            ventilated = pull(ventilated),
                                            units = match.arg(units_pao2_fio2))
  out[["SOFA_coag"]]   <- score_coagulation(pull(platelets))
  out[["SOFA_liver"]]  <- score_liver(pull(bilirubin),
                                      units = match.arg(units_bilirubin))
  out[["SOFA_cardio"]] <- score_cardiovascular(map            = pull(map),
                                               vasopressors   = pull(vasopressors),
                                               dopamine       = pull(dopamine),
                                               dobutamine     = pull(dobutamine),
                                               norepinephrine = pull(noradrenaline),
                                               epinephrine    = pull(epinephrine))
  out[["SOFA_neuro"]]  <- score_neurological(pull(gcs),
                                             sedation = pull(sedation))
  out[["SOFA_renal"]]  <- score_renal(pull(creatinine),
                                      urine_output = pull(urine_output),
                                      dialysis     = pull(dialysis),
                                      units = match.arg(units_creatinine))

  parts <- c("SOFA_resp", "SOFA_coag", "SOFA_liver",
             "SOFA_cardio", "SOFA_neuro", "SOFA_renal")
  na_rm <- na_strategy == "sum_na_zero"
  out[["SOFA_score"]] <- rowSums(out[parts], na.rm = na_rm)
  if (na_strategy == "propagate") {
    any_na <- apply(out[parts], 1, function(x) any(is.na(x)))
    out[["SOFA_score"]][any_na] <- NA_integer_
  }

  if (!is.null(id)) {
    if (!id %in% names(out)) {
      stop(sprintf("Column '%s' not found in `data`.", id), call. = FALSE)
    }
    if (!is.null(time)) {
      if (!time %in% names(out)) {
        stop(sprintf("Column '%s' not found in `data`.", time), call. = FALSE)
      }
      ord <- order(out[[id]], out[[time]])
      first_score <- stats::ave(out[["SOFA_score"]][ord],
                                out[[id]][ord],
                                FUN = function(x) x[1])
      out[["SOFA_admission"]] <- first_score[order(ord)]
    }
    out[["SOFA_max"]] <- stats::ave(out[["SOFA_score"]],
                                    out[[id]],
                                    FUN = function(x) max(x, na.rm = TRUE))
  }

  out
}
