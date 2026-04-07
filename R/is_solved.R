is_solved <- function(game) {
  clues <- game$clues
  segments <- game$segments
  n <- game$n

  for (i in 1:n) {
    for (j in 1:n) {
      val <- clues[i,j]
      if (!is.na(val)) {
        count <- segments$horiz[i,j] + segments$horiz[i+1,j] +
          segments$vert[i,j] + segments$vert[i,j+1]
        if (count != val) return(FALSE)
      }
    }
  }
  return(TRUE)
}
