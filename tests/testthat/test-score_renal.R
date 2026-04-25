test_that("renal creatinine thresholds in umol/L map to canonical scores", {
  expect_equal(score_renal(c(80, 130, 200, 350, 500)),
               c(0L, 1L, 2L, 3L, 4L))
})

test_that("renal creatinine thresholds in mg/dL convert correctly", {
  expect_equal(score_renal(c(0.9, 1.5, 2.5, 4, 6), units = "mg/dL"),
               c(0L, 1L, 2L, 3L, 4L))
})

test_that("urine output can escalate the score", {
  expect_equal(
    score_renal(creatinine   = c(80, 80, 80),
                urine_output = c(2000, 400, 100)),
    c(0L, 3L, 4L)
  )
})

test_that("dialysis pins the score at 4", {
  expect_equal(
    score_renal(creatinine = c(80, 80),
                dialysis   = c(0, 1)),
    c(0L, 4L)
  )
})
