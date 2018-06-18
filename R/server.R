#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(jsonlite)
library(tidyr)
#tidyverse<-left_join
library(tidyverse)


# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  localidad <- eventReactive(input$buscar , {
    ggmap::geocode(input$localidad)
  }, ignoreNULL = FALSE)

  cargaDato <- eventReactive(input$buscar , {
    #gps<-ggmap::geocode(input$localidad)
    #lati=gps$lat
    #long=gps$lon
    lati<-localidad()$lat
    long<-localidad()$lon
    url<-paste0("https://power.larc.nasa.gov/cgi-bin/v1/DataAccess.py?request=execute&identifier=SinglePoint&parameters=PRECTOT,T2M,T2M_MAX,T2M_MIN&startDate=1981&endDate=2017&userCommunity=AG&tempAverage=INTERANNUAL&outputList=JSON,ASCII&lat=",lati,"&lon=",long,"&user=anonymous%22")
    json_data <- fromJSON(url)
    table<-json_data[["features"]][["properties"]][["parameter"]]
    tablePre<-table$PRECTOT %>%
      gather( key = "date", value = "precipitation")
    tableMax<-table$T2M_MAX %>%
      gather( key = "date", value = "temp_max")
    tableMin<-table$T2M_MIN %>%
      gather( key = "date", value = "temp_min")
    tableTemp<-table$T2M %>%
      gather( key = "date", value = "temp")
    totalTable<-tablePre %>%
      left_join(tableTemp, by = "date")
    totalTable<-totalTable %>%
      left_join(tableMax, by = "date")
    totalTable<-totalTable %>%
      left_join(tableMin, by = "date")
    #from string to date
    totalTable$date<-parse_date(totalTable$date, "%Y%m")
    #add column "year"
    totalTable$year<-format(totalTable$date, "%Y")
    #add column "month"
    totalTable$month<-format(totalTable$date, "%m")
    #drop rows containing missing values
    totalTable<-drop_na(totalTable)
    #add column "tmm" precipitation total
    totalTable<-totalTable %>%
      mutate(tmm = precipitation * 30.5)
    totalTable$year<-as.integer(totalTable$year)
    totalTable$month<-as.integer(totalTable$month)
    totalTable<-totalTable%>%
      left_join(dataENSO)
    #totalTable$year<-format(totalTable$date, "%Y")
    #totalTable$month<-as.factor(totalTable$month)


  }, ignoreNULL = FALSE)



  tabla<-reactive({
  lati<-round(localidad()$lat, 2)
  long<-round(localidad()$lon,2)
  if (is.null(lati)){
    lati=-32.94
  }
  if (is.null(long)){
    long=-32.94
  }


  #table<-totalTable %>%
    #filter(year < ymd(20130102))
  filtredTable<-cargaDato() %>%
    filter( year >= input$date_range[1] )%>%
    filter( year <= input$date_range[2] )
  filtredTable
  })

  tabla1<-reactive({

    filtredTable1<-cargaDato() %>%
      filter( year >= input$date_range1[1] )%>%
      filter( year <= input$date_range1[2] )
    filtredTable1
  })

  output$distPlot <- renderPlot({
    as<-tabla()
    ggplot(as, aes(month, tmm, group=month, fill=type))+
      geom_boxplot()+
      theme(axis.line = element_line(color="orange", size=1))+scale_color_discrete()+scale_x_discrete(limits=c(1,2,3,4,5,6,7,8,9,10,11,12))+
      facet_wrap(~type)
  })

  output$distPlot1 <- renderPlot({
    as<-tabla()
    ggplot(as, aes(month, temp, group=month, fill=type))+
      geom_boxplot()+
      theme(axis.line = element_line(color="orange", size=1))+scale_color_discrete()+scale_x_discrete(limits=c(1,2,3,4,5,6,7,8,9,10,11,12))+
      facet_wrap(~type)
  })

  output$result <- renderText({
    datess<-input$date_range
    paste("You chose", input$department, input$localidad, localidad()$lat, localidad()$lon, datess[1], datess[2])
  })

  output$table <-renderTable({
    head( tabla())
  })

  output$results <- renderText({
    if (is.na(localidad()$lat)){
      paste("There are no results for your search (", input$localidad, ")")
    }
  })



  output$mymap <- renderLeaflet({

    if(!is.na(localidad()$lat)){
    leaflet(localidad(), options = leafletOptions(minZoom = 0, maxZoom = 7)) %>%
      addTiles() %>% addMarkers()}
    else{
      leaflet() %>%
        addTiles()
    }
  })



})
