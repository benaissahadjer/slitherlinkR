#' Créer une nouvelle partie de Slitherlink
#'
#' Cette fonction crée une grille vide de Slitherlink de taille n x n.
#'
#' @param n taille de la grille
#' @return un objet de type slitherlink
#' @export

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
