
test_that("pin_action() works for an r-lib action", {
  skip_if_offline()
  expected <- "r-lib/actions/check-r-package@14a7e741c1cb130261263aa1593718ba42cf443b #v2.11.2"
  res <- pin_action("r-lib/actions/check-r-package@v2.11.2")
  expect_equal(res, expected)

  # pin action will return early if fed twice:
  expect_equal(res, pin_action(res))
})

test_that("pin_action() works for a JamesIves action", {
  skip_if_offline()
  expected <- "JamesIves/github-pages-deploy-action@65b5dfd4f5bcd3a7403bbc2959c144256167464e #v4.5.0"
  res <- pin_action("JamesIves/github-pages-deploy-action@v4.5.0")
  expect_equal(res, expected)

  # pin action will return early if fed twice:
  expect_equal(res, pin_action(res))
})

test_that("pin_action() works for an action on a branch", {
  skip_if_offline()
  sha <- gh::gh("GET /repos/carpentries/actions/commits", per_page = 1)[[1]]$sha
  expected <- paste0("carpentries/actions/comment-diff@", sha, " #main")
  res <- pin_action("carpentries/actions/comment-diff@main")
  expect_equal(res, expected)

  # pin action will return early if fed twice:
  expect_equal(res, pin_action(res))
})


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


test_that("pin() will pin all workflows", {
  local_mocked_bindings(
    pin_action = function(action) {
      pin <- "14a7e741c1cb130261263aa1593718ba42cf443b #v2.11.2"
      sub("v2", pin, action, fixed = TRUE)
    }
  )
  path <- system.file("workflows", package = "pinsha")
  temp <- withr::local_tempdir()
  file.copy(path, temp, recursive = TRUE)
  pin(file.path(temp, "workflows"), write = TRUE)
  newpath <- file.path(temp, "workflows", "R-CMD-check.yaml")
  # workflow files are not equal 
  old <- readLines(fs::path(path, "R-CMD-check.yaml"))
  new <- readLines(newpath)
  expect_failure(expect_equal(old, new))
  # by default, the only actions updated are the third-party actions
  actions <- pin_find_actions(newpath, include_official = TRUE)
  refs <- unique(vapply(actions, function(x) parse_action(x)$ref, character(1)))
  expect_equal(refs, c("v4", "14a7e741c1cb130261263aa1593718ba42cf443b"))
  newpath <- file.path(temp, "workflows", "test-coverage.yaml")
  # workflow files are not equal 
  old <- readLines(fs::path(path, "test-coverage.yaml"))
  new <- readLines(newpath)
  expect_failure(expect_equal(old, new))
  # by default, the only actions updated are the third-party actions
  actions <- pin_find_actions(newpath, include_official = TRUE)
  refs <- unique(vapply(actions, function(x) parse_action(x)$ref, character(1)))
  expect_equal(refs, c("v4", "14a7e741c1cb130261263aa1593718ba42cf443b", "v5"))
})




