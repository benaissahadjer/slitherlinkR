#' Générer une grille de Slitherlink
#'
#' @param n taille de la grille
#' @return matrice des indices
#' @export

get_clues <- function(n, difficulte = "Facile") {

  params <- switch(difficulte,
                   "Facile" = list(
                     taille_min  = as.integer(n * 2),
                     taille_max  = as.integer(n * 3),
                     prob_masque = 0.20,
                     tortuosite  = 0.2,
                     prob_zero   = 0.85   # garder 15% des 0
                   ),
                   "Moyen" = list(
                     taille_min  = as.integer(n * 3),
                     taille_max  = as.integer(n * 5),
                     prob_masque = 0.40,
                     tortuosite  = 0.5,
                     prob_zero   = 0.90   # garder 10% des 0
                   ),
                   "Difficile" = list(
                     taille_min  = as.integer(n * 5),
                     taille_max  = as.integer(n * 8),
                     prob_masque = 0.60,
                     tortuosite  = 0.8,
                     prob_zero   = 0.95   # garder 5% des 0
                   ),
                   "Expert" = list(
                     taille_min  = as.integer(n * 7),
                     taille_max  = as.integer(n * 10),
                     prob_masque = 0.75,
                     tortuosite  = 0.95,
                     prob_zero   = 1.0    # aucun 0 affiché
                   )
  )

  repeat {
    horiz <- matrix(0, n+1, n)
    vert  <- matrix(0, n, n+1)

    si <- sample(2:(n-1), 1)
    sj <- sample(2:(n-1), 1)
    ci <- si; cj <- sj

    path_nodes    <- list(c(ci, cj))
    visited_edges <- list()
    directions    <- list(c(1,0), c(-1,0), c(0,1), c(0,-1))
    last_dir      <- NULL
    succes        <- FALSE

    for (step in 1:(n * n * 6)) {
      dirs_pond <- 1:4
      if (!is.null(last_dir)) {
        same_idx <- which(sapply(directions, function(d) all(d == last_dir)))
        if (length(same_idx) > 0) {
          poids <- rep(1, 4)
          poids[same_idx] <- ifelse(params$tortuosite > 0.5, 0.3, 3.0)
          dirs_pond <- sample(1:4, 4, prob = poids / sum(poids))
        }
      }

      moved <- FALSE
      for (d in dirs_pond) {
        dir <- directions[[d]]
        ni  <- ci + dir[1]
        nj  <- cj + dir[2]

        if (ni < 1 || ni > n+1 || nj < 1 || nj > n+1) next

        if (dir[1] == 1)  { ei <- ci;   ej <- cj;   type <- "v" }
        if (dir[1] == -1) { ei <- ci-1; ej <- cj;   type <- "v" }
        if (dir[2] == 1)  { ei <- ci;   ej <- cj;   type <- "h" }
        if (dir[2] == -1) { ei <- ci;   ej <- cj-1; type <- "h" }

        edge_key <- paste(type, ei, ej)
        if (edge_key %in% visited_edges) next

        if (ni == si && nj == sj && length(path_nodes) >= params$taille_min) {
          if (type == "v") vert[ei, ej]  <- 1
          else             horiz[ei, ej] <- 1
          succes <- TRUE
          break
        }

        already <- any(sapply(path_nodes, function(p) p[1]==ni && p[2]==nj))
        if (already) next
        if (length(path_nodes) >= params$taille_max) next

        if (type == "v") vert[ei, ej]  <- 1
        else             horiz[ei, ej] <- 1

        visited_edges[[length(visited_edges)+1]] <- edge_key
        last_dir <- dir
        ci <- ni; cj <- nj
        path_nodes[[length(path_nodes)+1]] <- c(ci, cj)
        moved <- TRUE
        break
      }

      if (succes) break
      if (!moved) break
    }

    if (succes) break
  }

  # --- Calculer les indices ---
  clues <- matrix(0L, n, n)
  for (i in 1:n) {
    for (j in 1:n) {
      clues[i,j] <- horiz[i,j] + horiz[i+1,j] +
        vert[i,j]   + vert[i,j+1]
    }
  }

  # --- Masquer selon la difficulté ---
  mask <- matrix(runif(n*n) < params$prob_masque, n, n)
  mask[clues == 3] <- FALSE
  if (difficulte == "Facile") mask[clues == 2] <- FALSE

  clues_masquees <- clues
  clues_masquees[mask] <- NA

  # Masquer les 0 avec probabilité selon difficulté
  zero_mask <- !is.na(clues_masquees) &
    clues_masquees == 0 &
    runif(n*n) < params$prob_zero
  clues_masquees[zero_mask] <- NA

  return(list(
    clues    = clues_masquees,
    solution = list(horiz = horiz, vert = vert)
  ))
}
