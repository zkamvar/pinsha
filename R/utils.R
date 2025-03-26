looks_like_sha <- function(sha) {
  grepl("^[a-fA-F0-9]{40}$", sha)
}

parse_action <- function(action) {
  parts <- strsplit(action, "/")[[1]]
  repo <- sub("[@].*", "", sprintf("%s/%s", parts[1], parts[2]))
  action_version <- strsplit(parts[length(parts)], "@")[[1]]
  if (length(parts) > 2) {
    full <- sprintf("%s/%s", repo, action_version[1])
  } else {
    full <- repo
  }

  ref <- sub("\\s*[#].*$", "", action_version[2])
  list(full = full, repo = repo, ref = ref)
}

