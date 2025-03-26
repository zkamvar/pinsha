test_that("SHAs look like SHAs", {
  make_sha <- function(poison = NULL) {
    sha_like <- c(letters[1:6], LETTERS[1:6], 0:9)
    sha <- sample(sha_like, 40, replace = TRUE)
    if (!is.null(poison)) {
      sha[sample(40, 1)] <- poison
    }
    paste(sha, collapse = "")
  }
  expect_true(looks_like_sha(make_sha()))
  expect_false(looks_like_sha(substring(make_sha(), 1, 39)))
  expect_false(looks_like_sha(make_sha(poison = "z")))
  expect_false(looks_like_sha("v32"))
  expect_false(looks_like_sha("badbadbad"))
})



test_that("parse_action can parse an action", {
  expect_equal(parse_action("JamesIves/github-pages-action@v4.6.1"),
    list(
      full = "JamesIves/github-pages-action",
      repo = "JamesIves/github-pages-action",
      ref = "v4.6.1"
    )
  )
  expect_equal(parse_action("r-lib/actions/check-r-package@v2"),
    list(
      full = "r-lib/actions/check-r-package",
      repo = "r-lib/actions",
      ref = "v2"
    )
  )
  expect_equal(parse_action("carpentries/actions/comment-diff@main"),
    list(
      full = "carpentries/actions/comment-diff",
      repo = "carpentries/actions",
      ref = "main"
    )
  )
  expect_equal(parse_action("carpentries/actions/comment-diff"),
    list(
      full = "carpentries/actions/comment-diff",
      repo = "carpentries/actions",
      ref = NA_character_
    )
  )

})

