create_game <- function(n) {
  grid <- matrix(NA, n, n)

  game <- list(
    grid = grid,
    n = n
  )

  class(game) <- "slitherlink"

  return(game)
}