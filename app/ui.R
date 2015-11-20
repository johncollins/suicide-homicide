library(ggplot2)
library(shiny)

shinyUI(pageWithSidebar(
    headerPanel('Suicide versus Homicide rates around the world'),
    sidebarPanel(
        h3('Choose a view'),
        radioButtons("choice", "",
                     c("Suicide Rates (per 100K)" = "suicide",
                       "Homicide Rates (per 100K)" = "homicide",
                       "Homicide >= Suicide" = "hom_ge")),
        h6('Note: Gray indicates that no information was available')
    ),
    mainPanel(
        plotOutput('map')
    )
))
#plot_map1('homicide')
#plot_map2('suicide')
