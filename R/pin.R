#' Pin an individual action to its corresponding SHA
#'
#' @param action the action written with github syntax that contains at least
#'   the github user, repo, and tag
#' @return the same action with an SHA and a comment that indicates the tag
#'   the sha belongs to (this may be different than the tag if you use a floating tag)
#' @export
#' @examples
#' # pin a specific release
#' pin_action("r-lib/actions/check-r-package@v2")
#' # pin the latest release
#' pin_action("docker/login-action")
pin_action <- function(action = "r-lib/actions/check-r-package@v2") {
  act <- parse_action(action)
  # Make sure we aren't going in loops
  if (looks_like_sha(act$ref)) {
    return(action)
  }
  # No ref will fetch the latest release or tag
  if (length(act$ref) == 1 && is.na(act$ref)) {
    act$ref <- tryCatch({
        gh("GET /repos/{repo}/releases", repo = act$repo)[[1]]$tag_name
      },
      http_error_404 = function(e) {
        gh("GET /repos/{repo}/tags", repo = act$repo)[[1]]$name
      }
    )
  }
  # attempt to fetch the SHA from the current tag
  sha <- tryCatch({
      res <- gh(
        "GET /repos/{repo}/git/refs/tags/{tag}",
        repo = act$repo,
        tag = act$ref
      )$object$sha
      class(res) <- "tag"
      res
    },
    http_error_404 = function(e) {
      # If the tag cannot be obtained, then that likely means its a branch
      res <- gh(
        "GET /repos/{repo}/git/refs/heads/{tag}",
        repo = act$repo,
        tag = act$ref
      )$object$sha
      res
    })

  # For tags, we need to get the first tag that matches the SHA, which shoud
  # be the official (non-floating) tag.
  if (inherits(sha, "tag")) {
    gh_tags <- gh("GET /repos/{repo}/tags", repo = act$repo)
    for (i in gh_tags) {
      if (i$commit$sha == sha) {
        vtag <- i$name
        break
      }
    }
  } else {
    vtag <- act$ref
  }
  sprintf("%s@%s #%s", act$full, sha, vtag)
}

#' Find GitHub actions used in a workflow file
#'
#' @param workflow the path to a github workflow file
#' @param include_official when `TRUE`, official actions (that have the
#' organization name of `actions/`) will be included in the results. Defaults
#' to `FALSE`.
#' @return a character vector of zero or more actions used in your workflows
#' @export
#' @examples
#' workflows <- system.file("workflows", package = "pinsha")
#' pin_find_actions(workflows)
#' pkgdown <- system.file("workflows", "pkgdown.yaml", package = "pinsha")
#' pin_find_actions(pkgdown)
pin_find_actions <- function(workflow = ".github/workflows/R-CMD-check.yaml", include_official = FALSE) {
  if (fs::is_dir(workflow)) {
    return(lapply(fs::dir_ls(workflow, glob = "*y*ml"), pin_find_actions))
  }
  lines <- readLines(workflow)
  users <- trimws(sub("-*\\s*uses\\:\\s*", "", lines[grepl("uses:", lines, fixed = TRUE)]))
  res <- unique(users)
  if (!include_official) {
    return(res[!startsWith(res, "actions")])
  }
  res
}

#' Pin a third-party action in a workflow
#'
#' @inheritParams pin_action
#' @inheritParams pin_find_actions
#' @param write if `TRUE`, the workflow file will be overwritten. Defaults to
#'   `FALSE`, which leaves the workflow file intact
#' @param replacement (optional) the replacement for the particular action. If
#'   this is not provided (default), [pin_action()] will be used to find the
#'   replacement
#' @return a character vector of the workflow file with the actions replaced.
#' @export
#' @examplesIf requireNamespace("withr", silently = TRUE)
#' pkgdown <- withr::local_tempdir()
#' fs::file_copy(system.file("workflows", "pkgdown.yaml", package = "pinsha"), pkgdown)
#' actions <- pin_find_actions(pkgdown)
#' actions
#' for (action in actions) pin_action_workflow(action, workflow = pkgdown, write = TRUE)
#' pin_find_actions(pkgdown)
pin_action_workflow <- function(action = "r-lib/actions/check-r-package@v2", replacement = NULL, workflow = ".github/workflows/R-CMD-check.yaml", write = FALSE) {
  lines <- readLines(workflow)
  if (is.null(replacement)) {
    replacement <- pin_action(action)
  }
  new_lines <- sub(action, replacement, lines, fixed = TRUE)
  if (write) {
    writeLines(new_lines, workflow)
  }
  new_lines
}

#' Automatically pin all actions to their expected hashes in your GitHub workflows
#' 
#' @param workflows the directory to your github workflows
#' @param include_official when `TRUE`, official github action workflows will also be pinned. Defaults to `FALSE`, meaning that the official workflows will continue to use tags
#' @param write When `TRUE`, the workflows will be overwritten. Defaults to `FALSE`
#' @export
#' @return nothing. Used for its side-effect
#' @examplesIf requireNamespace("withr", silently = TRUE)
#' tmp <- withr::local_tempdir()
#' workflows <- fs::path(tmp, ".github", "workflows")
#' fs::dir_copy(system.file("workflows", package = "pinsha"), workflows)
#' withr::with_dir(tmp, pin_find_actions(".github/workflows"))
#' withr::with_dir(tmp, pin(write = TRUE))
#' withr::with_dir(tmp, pin_find_actions(".github/workflows"))
pin <- function(workflows = ".github/workflows", include_official = FALSE, write = FALSE) {
  workflows <- fs::dir_ls(workflows, glob = "*.y*ml")
  actions <- unique(unlist(lapply(workflows, pin_find_actions), use.names = FALSE))
  pins <- vapply(actions, pin_action, character(1))
  names(pins) <- actions
  for (workflow in workflows) {
    for (action in actions) {
      pin_action_workflow(action, pins[action], workflow = workflow, write = write)
    }
  }
}
