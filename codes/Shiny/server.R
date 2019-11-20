#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(ggradar)
library(ggplot2)


# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    output$map <- renderLeaflet({
      if (input$state == 'All'){
        temp <- business
      }
      else if (input$state != 'All' & input$city == 'All'){
        temp <- business[business$state == input$state, ]
      }
      else if (input$state != 'All' & input$city != 'All' & input$business_id == 'All') {
        temp <- business[(business$state == input$state)&(business$city == input$city), ]
      }
      else {
        temp <- business[(business$state == input$state)&(business$city == input$city)&(business$business_id==input$business_id), ]
      }
        leaflet(temp) %>% addTiles() %>% addMarkers(temp$longitude, temp$latitude, 
            clusterOptions = markerClusterOptions(),
            popup=paste(temp$name,  temp$city, temp$state, 'Star:', temp$stars, sep="\n"))
    })
  
    
    city_choice <- reactive({
      c("All", as.character(unique(business[business$state==input$state, ]$city)))
    })
    
    bus_choice <- reactive({
      c("All", as.character(business[(business$state==input$state)&(business$city==input$city), ]$business_id))
    })
    
    observe({
      updateSelectInput(session, 'city', choices=city_choice())
    })
    
    observe({
      updateSelectInput(session, 'business_id', choices=bus_choice())
    })
    

    
    
    output$density_plot <- renderPlot({
      if (input$state == 'All'){
        temp <- business
      }
      else if (input$state != 'All' & input$city == 'All'){
        temp <- business[business$state == input$state, ]
      }
      else if (input$state != 'All' & input$city != 'All' & input$business_id == 'All') {
        bbb <- business[(business$state == input$state)&(business$city == input$city), ]$business_id
        temp <- review[review$business_id %in% bbb, ]
      }
      else {
        temp <- review[review$business_id == input$business_id, ]
      }
      
      ggplot(temp, aes(x=stars)) + geom_bar(color="darkblue", fill="lightblue")
      
      # x <- temp$stars
      # h <- hist(x, breaks = 10, col='red', main = 'Histogram of Stars', xlab = 'Stars')
      # xfit <- seq(min(x), max(x), length=40)
      # yfit <- dnorm(xfit, mean = mean(x), sd=sd(x))
      # yfit <- yfit*diff(h$mids[1:2])*length(x)
      # lines(xfit, yfit, col='blue', lwd=2)
    })
    
    
    output$radar <- renderPlot({
      if (input$business_id == 'All'){
        return(list(src = "pp.png", width = 500, height = 300, alt = "Face"))
      }
      else if (!(input$business_id %in% business$business_id)){
        return(list(src = "pp.png", width = 500, height = 300, alt = "Face"))
      }
      else {
        ggradar(rad[rad$business_id==input$business_id, ], grid.min = 0, grid.max = 5, grid.mid=2,
                values.radar = c(1, 2, 5))
      }
    })
    
    
    output$suggest <- renderText({
      if (input$business_id=='All'){
        "Please select business_id first!"
      }
      else{
        if (input$business_id %in% business$business_id){
          as.character(suggestions[suggestions$business_id==input$business_id, 'suggestion'])
        }
        else{
          "Missing too many attributes and we can't give suggestions!"
        }
      }
    })
    
    output$tt <- renderTable({
      if (input$business_id=='All'){
        temp <- as.data.frame("Please select business_id first!")
      }
      else{
        if (input$business_id %in% business$business_id){
          temp <- as.data.frame(strsplit(suggestions[suggestions$business_id==input$business_id, 'suggestion'], "\\|")[[1]])
          
          
        }
        else{
          temp <- as.data.frame("Missing too many attributes and we can't give suggestions!")
        }
      }
      colnames(temp) <- 'Suggestions'
      temp
    })
    
    
    
    
})
