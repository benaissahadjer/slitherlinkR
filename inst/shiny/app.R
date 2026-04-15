library(shiny)

# source("../../R/create_game.R")
# source("../../R/is_solved.R")
# source("../../R/get_clues.R")

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@400;700&display=swap');

      body {
        background: radial-gradient(circle at top left, #6c5ce7 0%, #a29bfe 100%);
        font-family: 'Outfit', sans-serif;
        color: #2d3436;
        min-height: 100vh;
        margin: 0;
        padding-bottom: 40px;
      }

      /* Container Principal */
      .main-app-card {
        background: rgba(255, 255, 255, 0.9);
        backdrop-filter: blur(10px);
        border-radius: 30px;
        padding: 30px;
        box-shadow: 0 25px 50px rgba(0,0,0,0.2);
        max-width: 1000px;
        margin: 40px auto;
        border: 1px solid rgba(255,255,255,0.3);
      }

      /* Header Centré */
      .game-header {
        text-align: center;
        margin-bottom: 40px;
      }

      .game-header h1 {
        font-weight: 800;
        font-size: 3rem;
        background: linear-gradient(to right, #6c5ce7, #d63031);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        margin: 0;
      }

      /* Alignement des colonnes */
      .flex-container {
        display: flex;
        align-items: flex-start; /* Aligne le haut des deux colonnes */
        gap: 20px;
      }

      .sidebar-custom {
        background: #f8f9fa;
        padding: 20px;
        border-radius: 20px;
        flex: 1; /* Prend moins de place */
      }

      .game-container {
        flex: 2; /* La grille prend plus de place mais reste alignée */
        text-align: center;
      }

      /* Grille de jeu */
      .plot-box {
        background: white;
        padding: 10px;
        border-radius: 20px;
        box-shadow: inset 0 0 10px rgba(0,0,0,0.05);
        border: 1px solid #eee;
      }

      /* Boutons */
      .btn-game {
        border-radius: 12px !important;
        padding: 10px !important;
        font-weight: 700 !important;
        border: none !important;
        margin-bottom: 10px;
        width: 100%;
        color: white !important;
        transition: all 0.2s;
      }

      .btn-game:hover { transform: scale(1.02); filter: brightness(1.1); }
      .btn-new { background: #6c5ce7 !important; }
      .btn-check { background: #00b894 !important; }
      .btn-reset { background: #fdcb6e !important; color: #2d3436 !important; }
      .btn-sol { background: #ff7675 !important; }

      .status-bubble {
        background: #2d3436;
        color: #fff;
        padding: 12px;
        border-radius: 15px;
        font-weight: 600;
        margin-top: 15px;
        font-size: 14px;
      }
    "))
  ),

  div(class = "main-app-card",
      div(class = "game-header",
          h1("SLITHERLINK"),
          p("Complétez la boucle fermée", style="color:#636e72;")
      ),

      # Utilisation du Flexbox pour l'alignement parfait
      div(class = "flex-container",

          # Colonne de GAUCHE
          div(class = "sidebar-custom",
              selectInput("niveau", "DIFFICULTÉ",
                          choices = c("Facile", "Moyen", "Difficile", "Expert")),
              actionButton("new", "Nouvelle Partie", class = "btn-game btn-new", icon = icon("rocket")),
              actionButton("check", "Vérifier", class = "btn-game btn-check", icon = icon("shield-check")),
              hr(),
              actionButton("reset", "Effacer", class = "btn-game btn-reset", icon = icon("eraser")),
              actionButton("show_solution", "Solution", class = "btn-game btn-sol", icon = icon("magic"))
          ),

          # Colonne de DROITE (Grille)
          div(class = "game-container",
              div(class = "plot-box",
                  # Hauteur fixée à 450px pour rester au niveau du menu
                  plotOutput("gridPlot", click = "plot_click", height = "450px")
              ),
              div(class = "status-bubble",
                  textOutput("status")
              )
          )
      )
  )
)

server <- function(input, output, session) {

  segments <- reactiveValues(horiz = NULL, vert = NULL)
  game <- reactiveVal(NULL)
  status_text <- reactiveVal("Prêt ? Sélectionnez un niveau.")

  observeEvent(input$new, {
    n <- switch(input$niveau, "Facile" = 5, "Moyen" = 7, "Difficile" = 10, "Expert" = 12)
    game(create_game(n, input$niveau))
    segments$horiz <- matrix(0, n+1, n)
    segments$vert  <- matrix(0, n, n+1)
    status_text("Bonne chance !")
  })

  observeEvent(input$plot_click, {
    req(game(), segments$horiz)
    x <- input$plot_click$x
    y <- input$plot_click$y
    n <- game()$n
    j_float <- x
    i_float <- n - y
    j <- floor(j_float) + 1
    i <- floor(i_float) + 1
    dx <- j_float - floor(j_float)
    dy <- i_float - floor(i_float)
    min_dist <- min(dy, 1-dy, dx, 1-dx)

    if (min_dist > 0.35) return()

    if (min_dist == dy && i >= 1 && i <= n+1 && j >= 1 && j <= n) {
      segments$horiz[i, j] <- 1 - segments$horiz[i, j]
    } else if (min_dist == (1-dy) && i+1 <= n+1 && j >= 1 && j <= n) {
      segments$horiz[i+1, j] <- 1 - segments$horiz[i+1, j]
    } else if (min_dist == dx && i >= 1 && i <= n && j >= 1 && j <= n+1) {
      segments$vert[i, j] <- 1 - segments$vert[i, j]
    } else if (min_dist == (1-dx) && i >= 1 && i <= n && j+1 <= n+1) {
      segments$vert[i, j+1] <- 1 - segments$vert[i, j+1]
    }
  })

  observeEvent(input$reset, {
    req(game())
    segments$horiz[] <- 0
    segments$vert[] <- 0
    status_text("Grille réinitialisée.")
  })

  observeEvent(input$check, {
    req(game())
    g <- game()
    g$segments <- list(horiz = segments$horiz, vert = segments$vert)
    if (is_solved(g)) status_text("🏆 VICTOIRE !")
    else status_text("❌ Pas encore correct...")
  })

  observeEvent(input$show_solution, {
    req(game())
    segments$horiz <- game()$solution$horiz
    segments$vert  <- game()$solution$vert
    status_text("Solution affichée.")
  })

  output$gridPlot <- renderPlot({
    req(game())
    n <- game()$n
    par(mar = c(0.5, 0.5, 0.5, 0.5), bg = "white")

    plot(c(-0.2, n+0.2), c(-0.2, n+0.2), type = "n", xlab = "", ylab = "",
         xaxt = "n", yaxt = "n", bty = "n", asp = 1)

    for (i in 0:n) {
      for (j in 0:n) {
        points(j, i, pch = 21, bg = "#dcdde1", col = "white", cex = 1.2)
      }
    }

    for (i in 1:n) {
      for (j in 1:n) {
        val <- game()$clues[i, j]
        if (!is.na(val)) {
          text(j - 0.5, n - i + 0.5, labels = val, cex = 1.5, font = 2, col = "#2f3640")
        }
      }
    }

    line_col <- "#6c5ce7"
    if (!is.null(segments$horiz)) {
      for (i in 1:(n+1)) for (j in 1:n) {
        if (segments$horiz[i, j] == 1) segments(j-1, n-i+1, j, n-i+1, lwd = 5, col = line_col, lend = 1)
      }
    }
    if (!is.null(segments$vert)) {
      for (i in 1:n) for (j in 1:(n+1)) {
        if (segments$vert[i, j] == 1) segments(j-1, n-i+1, j-1, n-i, lwd = 5, col = line_col, lend = 1)
      }
    }
  })

  output$status <- renderText({ status_text() })
}

shinyApp(ui, server)
