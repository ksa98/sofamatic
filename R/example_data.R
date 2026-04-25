#' Synthetic ICU example data
#'
#' Returns a synthetic, longitudinal data set in the layout typical of an
#' ICU case-report form: one row per (subject, day) with the columns needed
#' by [calculate_sofa()] plus a few demographic / context columns.
#'
#' **The data are entirely simulated and contain no patient information.**
#' Distributions are loosely calibrated to be plausible on an adult ICU
#' service (e.g., `pao2_fio2` skewing low for ventilated patients, occasional
#' missing `gcs` for sedated patients, ~10 % dialysis prevalence) but they
#' should never be used to draw clinical conclusions.
#'
#' @param n_subjects Number of subjects.
#' @param days_each Number of consecutive observation days per subject.
#' @param seed Optional integer seed for reproducibility (default `42`).
#'
#' @return A data frame with `n_subjects * days_each` rows and the following
#'   columns:
#'   \describe{
#'     \item{`subject_id`}{integer subject id}
#'     \item{`day`}{0-indexed day since admission}
#'     \item{`age`}{years}
#'     \item{`sex`}{`"F"`/`"M"`}
#'     \item{`bmi`}{kg/m²}
#'     \item{`pao2_fio2`}{kPa}
#'     \item{`ventilated`}{0/1}
#'     \item{`platelets`}{10⁹/L}
#'     \item{`bilirubin`}{µmol/L}
#'     \item{`vasopressors`}{0/1 flag}
#'     \item{`noradrenaline`}{µg/kg/min}
#'     \item{`map`}{mmHg}
#'     \item{`sedation`}{0/1}
#'     \item{`gcs`}{3–15 (with occasional `NA` for sedated patients)}
#'     \item{`creatinine`}{µmol/L}
#'     \item{`urine_output`}{mL/24h}
#'     \item{`dialysis`}{0/1}
#'   }
#'
#' @examples
#' df <- example_sofa_data(n_subjects = 5, days_each = 4)
#' head(df)
#'
#' @export
example_sofa_data <- function(n_subjects = 10,
                              days_each  = 5,
                              seed       = 42) {
  if (!is.null(seed)) set.seed(seed)
  ids  <- rep(seq_len(n_subjects), each = days_each)
  days <- rep(seq_len(days_each) - 1L, times = n_subjects)
  n    <- length(ids)

  # Subject-level static traits
  age_per_subject <- round(stats::rnorm(n_subjects, 62, 12))
  sex_per_subject <- sample(c("F", "M"), n_subjects, replace = TRUE,
                            prob = c(0.4, 0.6))
  bmi_per_subject <- round(stats::rnorm(n_subjects, 27, 5), 1)

  ventilated <- sample(c(0, 1), n, replace = TRUE, prob = c(0.15, 0.85))
  sedation   <- sample(c(0, 1), n, replace = TRUE, prob = c(0.45, 0.55))

  # PaO2/FiO2 in kPa: lower (worse) when ventilated
  pao2_fio2 <- round(ifelse(ventilated == 1,
                            stats::rnorm(n, 25, 8),
                            stats::rnorm(n, 50, 8)), 1)
  pao2_fio2 <- pmax(pao2_fio2, 5)

  # Vasopressor and noradrenaline doses
  vasopressors  <- sample(c(0, 1), n, replace = TRUE, prob = c(0.6, 0.4))
  noradrenaline <- ifelse(
    vasopressors == 1,
    round(pmax(0.001, stats::rnorm(n, 0.06, 0.05)), 3),
    0
  )

  # MAP — slightly lower when on vasopressors
  map <- round(stats::rnorm(n, mean = ifelse(vasopressors == 1, 70, 80),
                            sd = 10), 1)

  # GCS — random in 3–15, sometimes NA when sedated
  gcs <- sample(3:15, n, replace = TRUE)
  gcs[sedation == 1 & stats::runif(n) < 0.25] <- NA

  data.frame(
    subject_id    = ids,
    day           = days,
    age           = rep(age_per_subject, each = days_each),
    sex           = rep(sex_per_subject, each = days_each),
    bmi           = rep(bmi_per_subject, each = days_each),
    pao2_fio2     = pao2_fio2,
    ventilated    = ventilated,
    platelets     = round(pmax(5, stats::rnorm(n, 180, 70))),
    bilirubin     = round(pmax(2, stats::rnorm(n, 25, 25))),
    vasopressors  = vasopressors,
    noradrenaline = noradrenaline,
    map           = map,
    sedation      = sedation,
    gcs           = gcs,
    creatinine    = round(pmax(20, stats::rnorm(n, 110, 60))),
    urine_output  = round(pmax(0, stats::rnorm(n, 1500, 600))),
    dialysis      = sample(c(0, 1), n, replace = TRUE, prob = c(0.92, 0.08)),
    stringsAsFactors = FALSE
  )
}
