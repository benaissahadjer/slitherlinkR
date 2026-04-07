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
          plotOutput("grid", height = "500px")
      ),
      div(class = "status-box",
          textOutput("status")
      )
    )
  )
)

server <- function(input, output, session) {

  game <- reactiveVal(NULL)
  status_text <- reactiveVal("Choisissez une difficulté puis lancez une nouvelle partie.")

  observeEvent(input$new, {
    n <- if (input$niveau == "Facile") 5 else if (input$niveau == "Moyen") 7 else 10
    game(create_game(n))
    status_text("Jeu en cours")
  })

  observeEvent(input$reset, {
    req(game())
    n <- game()$n
    game(create_game(n))
    status_text("Grille réinitialisée")
  })

  observeEvent(input$check, {
    req(game())
    if (is_solved(game())) {
      status_text("Bravo, la solution est correcte !")
    } else {
      status_text("La solution n'est pas encore correcte.")
    }
  })

  output$grid <- renderPlot({
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
  })

  output$status <- renderText({
    status_text()
  })
}

shinyApp(ui, server)
