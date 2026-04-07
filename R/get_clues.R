get_clues <- function(n) {
  sample(c(NA, 0, 1, 2, 3), n * n, replace = TRUE,
         prob = c(0.35, 0.15, 0.2, 0.2, 0.1)) |>
    matrix(nrow = n, ncol = n)
}