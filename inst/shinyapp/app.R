library(shiny)
library(leaflet)

ui <- fluidPage(
  titlePanel("Internet Routing"),
  sidebarLayout(
    sidebarPanel(
      textInput("ip", "Target IP:", "8.8.8.8"),
      actionButton("go", "Analyze")
    ),
    mainPanel(
      leafletOutput("map"),
      tableOutput("table")
    )
  )
)

server <- function(input, output) {
  output$map <- renderLeaflet({ # nolint
    leaflet() %>% addTiles() %>% setView(0, 0, 2) # nolint
  })
  output$table <- renderTable({ # nolint
    data.frame(IP = input$ip, Status = "Analyzed")
  })
}

shinyApp(ui, server)