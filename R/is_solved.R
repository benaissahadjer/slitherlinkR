#' Vérifier si la solution est correcte
#'
#' @param game objet slitherlink
#' @return TRUE ou FALSE
#' @export

is_solved <- function(game) {
  clues    <- game$clues
  segments <- game$segments
  n        <- game$n
  horiz    <- segments$horiz
  vert     <- segments$vert

  # --- 1. Vérifier les contraintes numériques ---
  for (i in 1:n) {
    for (j in 1:n) {
      val <- clues[i, j]
      if (!is.na(val)) {
        count <- horiz[i, j] + horiz[i+1, j] +
          vert[i, j]  + vert[i, j+1]
        if (count != val) return(FALSE)
      }
    }
  }

  # --- 2. Chaque nœud a exactement 0 ou 2 segments ---
  for (i in 1:(n+1)) {
    for (j in 1:(n+1)) {
      deg <- 0
      if (j <= n)  deg <- deg + horiz[i, j]
      if (j > 1)   deg <- deg + horiz[i, j-1]
      if (i <= n)  deg <- deg + vert[i, j]
      if (i > 1)   deg <- deg + vert[i-1, j]
      if (deg != 0 && deg != 2) return(FALSE)
    }
  }

  # --- 3. Au moins un segment ---
  if (sum(horiz) + sum(vert) == 0) return(FALSE)

  # --- 4. Connexité : trouver le premier nœud actif ---
  start_i <- NA; start_j <- NA
  for (i in 1:(n+1)) {
    for (j in 1:(n+1)) {
      deg <- 0
      if (j <= n) deg <- deg + horiz[i, j]
      if (j > 1)  deg <- deg + horiz[i, j-1]
      if (i <= n) deg <- deg + vert[i, j]
      if (i > 1)  deg <- deg + vert[i-1, j]
      if (deg == 2) { start_i <- i; start_j <- j; break }
    }
    if (!is.na(start_i)) break
  }

  if (is.na(start_i)) return(FALSE)

  # --- 5. Parcourir la boucle ---
  ci <- start_i; cj <- start_j
  pi <- -1;      pj <- -1   # nœud précédent fictif (impossible dans la grille)
  visited <- 1

  repeat {
    next_i <- NA; next_j <- NA

    # droite
    if (cj <= n && horiz[ci, cj] == 1 && !(ci == pi && cj+1 == pj)) {
      next_i <- ci; next_j <- cj + 1
    }
    # gauche
    if (is.na(next_i) && cj > 1 && horiz[ci, cj-1] == 1 && !(ci == pi && cj-1 == pj)) {
      next_i <- ci; next_j <- cj - 1
    }
    # bas
    if (is.na(next_i) && ci <= n && vert[ci, cj] == 1 && !(ci+1 == pi && cj == pj)) {
      next_i <- ci + 1; next_j <- cj
    }
    # haut
    if (is.na(next_i) && ci > 1 && vert[ci-1, cj] == 1 && !(ci-1 == pi && cj == pj)) {
      next_i <- ci - 1; next_j <- cj
    }

    if (is.na(next_i)) return(FALSE)

    # Retour au départ = boucle fermée
    if (next_i == start_i && next_j == start_j) break

    pi <- ci; pj <- cj
    ci <- next_i; cj <- next_j
    visited <- visited + 1

    if (visited > (n+1)^2) return(FALSE)
  }

  # Nombre de nœuds = nombre de segments => une seule boucle
  total_segments <- sum(horiz) + sum(vert)
  return(visited == total_segments)
}
