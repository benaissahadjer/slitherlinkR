library(shiny)

source("../../R/create_game.R")
source("../../R/is_solved.R")
source("../../R/get_clues.R")

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body {
        background-color: #f6f7fb;
        font-family: Arial, sans-serif;
      }

      .title-box {
        background: white;
        padding: 18px 25px;
        border-radius: 14px;
        margin-bottom: 20px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
      }

      .side-box, .game-box, .status-box {
        background: white;
        border-radius: 14px;
        padding: 20px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
      }

      .side-box {
        min-height: 320px;
      }

      .game-box {
        min-height: 520px;
      }

      .status-box {
        margin-top: 15px;
        font-size: 18px;
        font-weight: bold;
        text-align: center;
      }

      .btn {
        border-radius: 10px !important;
        margin-bottom: 10px;
      }

      .control-label {
        font-size: 18px;
        font-weight: bold;
      }
    "))
  ),

  fluidRow(
    column(
      12,
      div(class = "title-box",
          h1("Jeu Slitherlink", style = "margin-top: 0; margin-bottom: 0;")
      )
    )
  ),

  fluidRow(
    column(
      4,
      div(class = "side-box",
          selectInput(
            "niveau",
            "Choisir la difficulté :",
            choices = c("Facile", "Moyen", "Difficile"),
            selected = "Facile"
          ),

          actionButton("new", "Nouvelle partie", class = "btn-primary"),
          br(),
          actionButton("reset", "Réinitialiser", class = "btn-warning"),
          br(),
          actionButton("check", "Vérifier", class = "btn-success"),
          br(), br(),

          p("Objectif : tracer une boucle fermée qui respecte les nombres dans la grille.",
            style = "font-size:16px;")
      )
    ),

    column(
      8,
      div(class = "game-box",
          plotOutput("gridPlot", click = "plot_click")
      ),
      div(class = "status-box",
          textOutput("status")
      )
    )
  )
)

server <- function(input, output, session) {

  segments <- reactiveValues(
    horiz = NULL,
    vert = NULL
  )

  observeEvent(input$plot_click, {

    req(game())
    req(segments$horiz)

    x <- input$plot_click$x
    y <- input$plot_click$y
    n <- game()$n

    # position dans la grille
    j <- floor(x) + 1
    i <- floor(y) + 1

    # distance aux bords de la case
    dx <- x - floor(x)
    dy <- y - floor(y)

    # distance aux 4 côtés
    dist_top <- dy
    dist_bottom <- 1 - dy
    dist_left <- dx
    dist_right <- 1 - dx

    min_dist <- min(dist_top, dist_bottom, dist_left, dist_right)

    # haut
    if (min_dist == dist_top) {
      if (i >= 1 && i <= n+1 && j >= 1 && j <= n) {
        segments$horiz[i, j] <- 1 - segments$horiz[i, j]
      }
    }

    # bas
    else if (min_dist == dist_bottom) {
      if (i+1 >= 1 && i+1 <= n+1 && j >= 1 && j <= n) {
        segments$horiz[i+1, j] <- 1 - segments$horiz[i+1, j]
      }
    }

    # gauche
    else if (min_dist == dist_left) {
      if (i >= 1 && i <= n && j >= 1 && j <= n+1) {
        segments$vert[i, j] <- 1 - segments$vert[i, j]
      }
    }

    # droite
    else if (min_dist == dist_right) {
      if (i >= 1 && i <= n && j+1 >= 1 && j+1 <= n+1) {
        segments$vert[i, j+1] <- 1 - segments$vert[i, j+1]
      }
    }

  })

  game <- reactiveVal(NULL)



  status_text <- reactiveVal("Choisissez une difficulté puis lancez une nouvelle partie.")

  observeEvent(input$new, {
    n <- if (input$niveau == "Facile") 5 else if (input$niveau == "Moyen") 7 else 10
    game(create_game(n))
    segments$horiz <- matrix(0, n+1, n)
    segments$vert  <- matrix(0, n, n+1)
    status_text("Jeu en cours")
  })

  observeEvent(input$reset, {
    req(game())
    n <- game()$n
    game(create_game(n))
    segments$horiz <- matrix(0, n+1, n)
    segments$vert  <- matrix(0, n, n+1)
    status_text("Grille réinitialisée")
  })

  observeEvent(input$check, {
    req(game())
    g <- game()

    g$segments <- list(
      horiz = segments$horiz,
      vert = segments$vert
    )
    if (is_solved(g)) {
      status_text("Bravo, la solution est correcte !")
    } else {
      status_text("La solution n'est pas encore correcte.")
    }
  })

  output$gridPlot <- renderPlot({
    req(game())
    n <- game()$n

    plot(
      c(0, n), c(0, n),
      type = "n",
      xlab = "", ylab = "",
      main = paste("Grille", n, "x", n),
      xaxt = "n", yaxt = "n",
      bty = "n",
      asp = 1
    )

    for (i in 0:n) {
      abline(h = i, col = "grey70")
      abline(v = i, col = "grey70")
    }

    for (i in 1:n) {
      for (j in 1:n) {
        val <- game()$clues[i, j]
        if (!is.na(val)) {
          text(j - 0.5, n - i + 0.5, labels = val, cex = 1.2, font = 2)
        }
      }
    }
    # afficher segments horizontaux
    if (!is.null(segments$horiz)) {
      for (i in 1:nrow(segments$horiz)) {
        for (j in 1:ncol(segments$horiz)) {
          if (segments$horiz[i,j] == 1) {
            segments(j-1, i-1, j, i-1, lwd = 3)
          }
        }
      }
    }

    # afficher segments verticaux
    if (!is.null(segments$vert)) {
      for (i in 1:nrow(segments$vert)) {
        for (j in 1:ncol(segments$vert)) {
          if (segments$vert[i,j] == 1) {
            segments(j-1, i-1, j-1, i, lwd = 3)
          }
        }
      }
    }

  })



  output$status <- renderText({
    status_text()
  })
}

shinyApp(ui, server)
