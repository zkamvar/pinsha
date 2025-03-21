
test_that("pin_action() works for an individual action", {
  skip_if_offline()
  expected <- "r-lib/actions/check-r-package@14a7e741c1cb130261263aa1593718ba42cf443b #v2.11.2"
  res <- pin_action("r-lib/actions/check-r-package@v2.11.2")
  expect_equal(res, expected)
})

test_that("pin_action_workflow() will update an individual workflow", {
  pin <- "r-lib/actions/check-r-package@14a7e741c1cb130261263aa1593718ba42cf443b #v2.11.2"
  action <- "r-lib/actions/check-r-package@v2.11.2"
  workflow <- test_path("testdata", "R-CMD-check.yaml")
  temp <- withr::local_tempfile()
  file.copy(workflow, temp)
  expected <- sub(action, pin, readLines(workflow), fixed = TRUE)
  # write will write to the new workflow
  expect_equal(pin_action_workflow(action, pin, temp, write = TRUE), expected)
  expect_equal(readLines(temp), expected)
})


test_that("pin_find_actions() will find all of the actions in the workflow", {
  workflow <- test_path("testdata", "R-CMD-check.yaml")
  r_actions <- c("setup-pandoc", "setup-r", "setup-r-dependencies", "check-r-package")
  expected <- c("actions/checkout@v4", paste0("r-lib/actions/", r_actions, "@v2"))

  expect_equal(pin_find_actions(workflow), expected[-1])
  expect_equal(pin_find_actions(workflow, include_official = TRUE), expected)
})


test_that("pin_all_workflows() will pin all workflows", {
  local_mocked_bindings(
    pin_action = function(action) {
      pin <- "14a7e741c1cb130261263aa1593718ba42cf443b #v2.11.2"
      sub("v2", pin, action, fixed = TRUE)
    }
  )
  temp <- withr::local_tempdir()
  file.copy(test_path("testdata"), temp, recursive = TRUE)
  pin_all_workflows(file.path(temp, "testdata"), write = TRUE)
  old <- readLines(test_path("testdata", "R-CMD-check.yaml"))
  new <- readLines(file.path(temp, "testdata", "R-CMD-check.yaml"))
  expect_failure(expect_equal(old, new))
})




