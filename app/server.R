library(shiny)

shinyServer(
    function(input, output){
        output$map <- renderPlot(get_map2(input$choice))
    }
)