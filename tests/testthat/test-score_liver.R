test_that("liver thresholds in umol/L map to canonical scores", {
  expect_equal(score_liver(c(15, 25, 50, 150, 250)),
               c(0L, 1L, 2L, 3L, 4L))
})

test_that("liver thresholds in mg/dL convert correctly", {
  expect_equal(score_liver(c(0.8, 1.5, 3, 8, 14), units = "mg/dL"),
               c(0L, 1L, 2L, 3L, 4L))
})

test_that("liver propagates NA", {
  expect_equal(score_liver(NA_real_), NA_integer_)
})
