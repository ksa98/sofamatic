test_that("respiratory thresholds in mmHg map to canonical scores", {
  expect_equal(
    score_respiratory(c(450, 350, 250, 150, 80),
                      ventilated = c(0, 0, 1, 1, 1),
                      units = "mmHg"),
    c(0L, 1L, 2L, 3L, 4L)
  )
})

test_that("respiratory thresholds in kPa match the MaastrICCht definition", {
  expect_equal(
    score_respiratory(c(60, 45, 30, 20, 10),
                      ventilated = c(0, 0, 1, 1, 1),
                      units = "kPa"),
    c(0L, 1L, 2L, 3L, 4L)
  )
})

test_that("non-ventilated patients are capped at 2 even with low PF", {
  expect_equal(
    score_respiratory(c(150, 80),
                      ventilated = c(0, 0),
                      units = "mmHg"),
    c(2L, 2L)
  )
})

test_that("ventilated arg can be omitted", {
  expect_equal(
    score_respiratory(c(450, 80), units = "mmHg"),
    c(0L, 4L)
  )
})

test_that("NA inputs propagate as NA", {
  expect_equal(score_respiratory(NA_real_, units = "mmHg"), NA_integer_)
})
