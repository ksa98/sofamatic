test_that("MAP-only path returns 0 / 1", {
  expect_equal(score_cardiovascular(map = c(80, 65)), c(0L, 1L))
})

test_that("norepinephrine dosing escalates the score", {
  expect_equal(
    score_cardiovascular(map = c(80, 65, 60, 60),
                         norepinephrine = c(0, 0, 0.05, 0.2)),
    c(0L, 1L, 3L, 4L)
  )
})

test_that("dopamine and dobutamine are scored", {
  expect_equal(
    score_cardiovascular(map = c(80, 80, 80, 80),
                         dopamine = c(0, 4, 10, 20)),
    c(0L, 2L, 3L, 4L)
  )
  expect_equal(
    score_cardiovascular(map = 80,
                         dobutamine = 5),
    2L
  )
})

test_that("epinephrine is scored", {
  expect_equal(
    score_cardiovascular(map = c(80, 80),
                         epinephrine = c(0.05, 0.2)),
    c(3L, 4L)
  )
})

test_that("vasopressors flag combined with norepinephrine matches MaastrICCht logic", {
  expect_equal(
    score_cardiovascular(map = c(80, 65, 60, 60),
                         vasopressors = c(0, 0, 1, 1),
                         norepinephrine = c(0, 0, 0.05, 0.2)),
    c(0L, 1L, 3L, 4L)
  )
})
