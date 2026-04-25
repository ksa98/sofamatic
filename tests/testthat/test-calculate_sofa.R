test_that("calculate_sofa adds all expected columns", {
  df <- example_sofa_data(n_subjects = 5, days_each = 3)
  out <- calculate_sofa(df, id = "subject_id", time = "day")

  expected_cols <- c("SOFA_resp", "SOFA_coag", "SOFA_liver",
                     "SOFA_cardio", "SOFA_neuro", "SOFA_renal",
                     "SOFA_score", "SOFA_admission", "SOFA_max")
  expect_true(all(expected_cols %in% names(out)))
})

test_that("calculate_sofa total is bounded in [0, 24]", {
  df <- example_sofa_data(n_subjects = 20, days_each = 5)
  out <- calculate_sofa(df)
  expect_true(all(out$SOFA_score >= 0 & out$SOFA_score <= 24, na.rm = TRUE))
})

test_that("SOFA_admission equals first-day SOFA per subject", {
  df <- example_sofa_data(n_subjects = 8, days_each = 4)
  out <- calculate_sofa(df, id = "subject_id", time = "day")
  by_subj <- split(out, out$subject_id)
  for (chunk in by_subj) {
    expect_equal(unique(chunk$SOFA_admission),
                 chunk$SOFA_score[which.min(chunk$day)])
  }
})

test_that("SOFA_max equals max SOFA per subject", {
  df <- example_sofa_data(n_subjects = 8, days_each = 4)
  out <- calculate_sofa(df, id = "subject_id")
  by_subj <- split(out, out$subject_id)
  for (chunk in by_subj) {
    expect_equal(unique(chunk$SOFA_max),
                 max(chunk$SOFA_score, na.rm = TRUE))
  }
})

test_that("calculate_sofa errors on a missing column", {
  df <- example_sofa_data(n_subjects = 2, days_each = 2)
  df$pao2_fio2 <- NULL
  expect_error(calculate_sofa(df), "pao2_fio2")
})

test_that("na_strategy='propagate' yields NA total when any subscore is NA", {
  df <- example_sofa_data(n_subjects = 4, days_each = 2)
  df$platelets[1] <- NA
  out <- calculate_sofa(df, na_strategy = "propagate")
  expect_true(is.na(out$SOFA_score[1]))
})
