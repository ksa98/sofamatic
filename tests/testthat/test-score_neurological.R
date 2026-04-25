test_that("neurological GCS bands map to canonical scores", {
  expect_equal(score_neurological(c(15, 14, 13, 12, 10, 9, 6, 5, 3)),
               c(0L, 1L, 1L, 2L, 2L, 3L, 3L, 4L, 4L))
})

test_that("NA GCS without sedation info is NA by default", {
  expect_equal(score_neurological(c(NA, 15)), c(NA_integer_, 0L))
})

test_that("NA GCS with sedation flag uses MaastrICCht convention", {
  expect_equal(
    score_neurological(c(NA, NA, 12),
                       sedation = c(0, 1, 1)),
    c(0L, 2L, 2L)
  )
})

test_that("na_strategy='zero' fills NA GCS with score 0", {
  expect_equal(score_neurological(c(NA, 15), na_strategy = "zero"),
               c(0L, 0L))
})
