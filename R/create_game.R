#' Créer une nouvelle partie de Slitherlink
#'
#' Initialise une partie complète de Slitherlink en générant :
#' - une grille de jeu
#' - les indices (clues)
#' - la solution complète
#'
#' Créer une nouvelle partie de Slitherlink
#'
#' Initialise une partie complète de Slitherlink en générant :
#' - une grille de jeu
#' - les indices (clues)
#' - la solution complète
#'
#' @param n entier. Taille de la grille (n x n)
#' @param difficulte caractère. Niveau de difficulté :
#'   "Facile", "Moyen", "Difficile", "Expert"
#'
#' @return Une liste de classe \code{slitherlink} contenant :
#' \itemize{
#'   \item \code{grid} : grille vide (non utilisée pour la logique actuelle)
#'   \item \code{clues} : matrice des indices du jeu
#'   \item \code{solution} : solution complète (segments horizontaux et verticaux)
#'   \item \code{n} : taille de la grille
#' }
#'
#' @export
create_game <- function(n, difficulte = "Facile") {

  resultat <- get_clues(n, difficulte)

  game <- list(
    grid     = matrix(NA, n, n),
    clues    = resultat$clues,
    solution = resultat$solution,
    n        = n
  )

  class(game) <- "slitherlink"
  return(game)
}
#' @export

create_game <- function(n, difficulte = "Facile") {
  # Génération de la grille + solution via get_clues()
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
