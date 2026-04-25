test_that("coagulation thresholds match the canonical SOFA definition", {
  expect_equal(score_coagulation(c(180, 130, 75, 35, 12)),
               c(0L, 1L, 2L, 3L, 4L))
})

test_that("coagulation handles boundary values correctly", {
  expect_equal(score_coagulation(c(150, 100, 50, 20)),
               c(0L, 1L, 2L, 3L))
})

test_that("coagulation propagates NA", {
  expect_equal(score_coagulation(c(NA, 100)), c(NA_integer_, 1L))
})
