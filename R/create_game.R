create_game <- function(n, difficulte = "Facile") {
  resultat  <- get_clues(n, difficulte)

  game <- list(
    grid     = matrix(NA, n, n),
    clues    = resultat$clues,
    solution = resultat$solution,   # la vraie solution est stockée
    n        = n
  )
  class(game) <- "slitherlink"
  return(game)
}
