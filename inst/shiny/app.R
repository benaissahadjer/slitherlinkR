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
            choices  = c("Facile", "Moyen", "Difficile", "Expert"),
            selected = "Facile"
          ),

          actionButton("new", "Nouvelle partie", class = "btn-primary"),
          br(),
          actionButton("reset", "Réinitialiser", class = "btn-warning"),
          br(),
          actionButton("check", "Vérifier", class = "btn-success"),
          br(), br(),
          actionButton("show_solution", "Voir solution", class = "btn-danger"),


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
    req(game(), segments$horiz)

    x <- input$plot_click$x
    y <- input$plot_click$y
    n <- game()$n

    # Conversion : plot (y=0 bas) -> matrice (i=1 haut)
    j_float <- x
    i_float <- n - y   # inversion de l'axe Y

    j <- floor(j_float) + 1
    i <- floor(i_float) + 1

    dx <- j_float - floor(j_float)
    dy <- i_float - floor(i_float)

    dist_top    <- dy
    dist_bottom <- 1 - dy
    dist_left   <- dx
    dist_right  <- 1 - dx

    min_dist <- min(dist_top, dist_bottom, dist_left, dist_right)
    if (min_dist > 0.35) return()

    if (min_dist == dist_top && i >= 1 && i <= n+1 && j >= 1 && j <= n) {
      segments$horiz[i, j] <- 1 - segments$horiz[i, j]
    } else if (min_dist == dist_bottom && i+1 <= n+1 && j >= 1 && j <= n) {
      segments$horiz[i+1, j] <- 1 - segments$horiz[i+1, j]
    } else if (min_dist == dist_left && i >= 1 && i <= n && j >= 1 && j <= n+1) {
      segments$vert[i, j] <- 1 - segments$vert[i, j]
    } else if (min_dist == dist_right && i >= 1 && i <= n && j+1 <= n+1) {
      segments$vert[i, j+1] <- 1 - segments$vert[i, j+1]
    }
  })

  game <- reactiveVal(NULL)



  status_text <- reactiveVal("Choisissez une difficulté puis lancez une nouvelle partie.")

  observeEvent(input$new, {
    n <- switch(input$niveau,
                "Facile"    = 5,
                "Moyen"     = 7,
                "Difficile" = 10,
                "Expert"    = 12
    )
    game(create_game(n, input$niveau))
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

  observeEvent(input$show_solution, {
    req(game())
    segments$horiz <- game()$solution$horiz
    segments$vert  <- game()$solution$vert
    status_text("Solution affichée")
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

    # Points aux intersections (coins des cases)
    for (i in 0:n) {
      for (j in 0:n) {
        points(j, i, pch = 16, cex = 0.6, col = "grey40")
      }
    }

    for (i in 1:n) {
      for (j in 1:n) {
        val <- game()$clues[i, j]
        if (!is.na(val)) {
          text(j - 0.5, n - i + 0.5, labels = val, cex = 1.2, font = 2)
        }
      }
    }
    # Segments horizontaux
    if (!is.null(segments$horiz)) {
      for (i in 1:(n+1)) {
        for (j in 1:n) {
          if (segments$horiz[i, j] == 1) {
            y_coord <- n - (i - 1)   # i=1 -> y=n (haut), i=n+1 -> y=0 (bas)
            segments(j - 1, y_coord, j, y_coord, lwd = 3, col = "red")
          }
        }
      }
    }

    # Segments verticaux
    if (!is.null(segments$vert)) {
      for (i in 1:n) {
        for (j in 1:(n+1)) {
          if (segments$vert[i, j] == 1) {
            y_top    <- n - (i - 1)  # bord haut de la ligne i
            y_bottom <- n - i        # bord bas de la ligne i
            segments(j - 1, y_top, j - 1, y_bottom, lwd = 3, col = "red")
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
