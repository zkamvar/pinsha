#' Pin an individual action to its corresponding SHA
#'
#' @param action the action written with github syntax that contains at least
#'   the github user, repo, and tag
#' @return the same action with an SHA and a comment that indicates the tag
#'   the sha belongs to (this may be different than the tag if you use a floating tag)
#' @export
#' @examples
#' pin_action("r-lib/actions/check-r-package@v2")
pin_action <- function(action = "r-lib/actions/check-r-package@v2") {
  parts <- strsplit(action, "/")[[1]]
  repo <- sub("[@].*", "", sprintf("%s/%s", parts[1], parts[2]))
  action_version <- strsplit(parts[length(parts)], "@")[[1]]
  if (length(parts) > 2) {
    full <- sprintf("%s/%s", repo, action_version[1])
  } else {
    full <- repo
  }

  tag <- action_version[2]
  sha <- gh::gh(
    "GET /repos/{repo}/git/refs/tags/{tag}", 
    repo = repo,
    tag = tag
  )$object$sha

  gh_tags <- gh::gh("GET /repos/{repo}/tags", repo = repo)
  for (i in gh_tags) {
    if (i$commit$sha == sha) {
      vtag <- i$name
      break
    }
  }
  sprintf("%s@%s #%s", full, sha, vtag)
}

pin_find_actions <- function(workflow = ".github/workflows/R-CMD-check.yaml", include_official = FALSE) {
  lines <- readLines(workflow)
  users <- trimws(sub("-\\s*uses\\:\\s*", "", lines[grepl("uses:", lines, fixed = TRUE)]))
  res <- unique(users)
  if (!include_official) {
    return(res[!startsWith(res, "actions")])
  }
  res
}

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
#' @examples
#' \dontrun{
#'   pin()
#' }
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
