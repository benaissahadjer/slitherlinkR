create_game <- function(n) {
  grid <- matrix(NA, n, n)
  clues <- get_clues(n)

  game <- list(
    grid = grid,
    clues = clues,
    n = n
  )

  class(game) <- "slitherlink"

  return(game)
}
