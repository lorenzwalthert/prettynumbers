context("test-integers")

test_that("without tick", {
  expect_equal(
    bare_numbers(2), "2"
  )
  expect_equal(
    bare_numbers(22), "22"
  )
  expect_equal(
    bare_numbers(422), "422"
  )
})


test_that("with tick", {
  expect_equal(
    bare_numbers(2001), "2'001 (~2 thousand)"
  )
  expect_equal(
    bare_numbers(32109876), "32'109'876 (~32 millions)"
  )
  expect_equal(
    bare_numbers(2e6), "2'000'000 (2 millions)"
  )
  expect_equal(
    bare_numbers(100000.83992384920384203948), "100'000.8399 (~100 thousand)"
  )
})
