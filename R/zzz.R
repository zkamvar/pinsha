.onLoad <- function(lib, pkg) {
  pin_action <<- memoise::memoise(pin_action)
}
