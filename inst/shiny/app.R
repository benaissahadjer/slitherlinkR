library(shiny)

source("../../R/create_game.R")
source("../../R/is_solved.R")
source("../../R/get_clues.R")

ui <- fluidPage(
  titlePanel("Jeu Slitherlink"),

  sidebarLayout(
    sidebarPanel(
      selectInput(
        "niveau",
        "Choisir difficulté :",
        choices = c("Facile", "Moyen", "Difficile")
      ),
      actionButton("new", "Nouvelle partie")
    ),

    mainPanel(
      plotOutput("grid"),
      textOutput("status")
    )
  )
)

server <- function(input, output) {

  game <- reactiveVal(NULL)

  observeEvent(input$new, {
    n <- if (input$niveau == "Facile") 5 else if (input$niveau == "Moyen") 7 else 10
    game(create_game(n))
  })

  output$grid <- renderPlot({
    req(game())
    n <- game()$n

    plot(1:n, 1:n, type = "n", xlab = "", ylab = "", main = paste("Grille", n, "x", n))

    for(i in 1:n) {
      abline(h = i)
      abline(v = i)
      for (i in 1:n) {
        for (j in 1:n) {
          val <- game()$clues[i, j]
          if (!is.na(val)) {
            text(j, n - i + 1, labels = val, cex = 1.2)
          }
        }
      }
    }
  })

  output$status <- renderText({
    if (is.null(game())) {
      return("Pas de jeu")
    }
    "Jeu en cours"
  })
}

shinyApp(ui, server)
