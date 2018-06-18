#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(ggmap)


# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("analysisArte: ENSO influence on local rainfall"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(width=3,
       sliderInput("date_range",
                   "Plot 1: Choose Year Range:",
                   min = 1981, max = 2017,
                   value = c(1987,2017)
       ),
       sliderInput("date_range1",
                   "Plot 2: Choose Year Range:",
                   min = 1981, max = 2017,
                   value = c(198,2012)
       ),
       textInput("localidad", "City", "Rosario, Santa Fe", placeholder ="Rosario, Santa Fe"),
       actionButton("buscar", "Search"),
       p(),
       leafletOutput("mymap"),
       textOutput("results")


    ),

    # Show a plot of the generated distribution
    mainPanel(width=9,
      column(12,
       plotOutput("distPlot"),
       plotOutput("distPlot1"),
       textOutput("result"),
       tableOutput("table")
      )
    )
  )
))
