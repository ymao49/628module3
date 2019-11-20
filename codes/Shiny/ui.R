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
library(ggradar)
library(ggplot2)


# Define UI for application that draws a histogram
shinyUI(fluidPage(
    h1(span("Yelp Steakhouse Navigation", style = "font-weight: 500"), 
       style = "font-family: 'Source Sans Pro'; text-align: center;padding: 20px"),
    sidebarLayout(
         sidebarPanel(
             selectInput("state", "State",choices = c("All", as.character(unique(business$state)))),

             selectInput("city", "City:", choices = c("All", as.character(unique(business$city)))),
             
             selectInput("business_id", "Name:", choices = c("All", as.character(business$business_id))),
             p("Note: In order to show radar plot and suggestions, please first select state, city and business_id!"),
             p("Note: If radar plot and distribution plot are not showed after selecting business id, it means for this store, we don't have enough data and can't show relative plots.")
             
         ),
         mainPanel(
             tabsetPanel(
                 tabPanel("Steakhouse Map", leafletOutput("map", width = "100%", height = 600)),
                 
                 tabPanel("Stars Distribution", plotOutput('density_plot', width = "100%", height = 600)),
                 tabPanel("Radar of reviews", plotOutput('radar', width = "100%", height = 600)),
                 tabPanel("Suggestions from Attributes", tableOutput('tt'))
             )
         )
         )

    )
    
    
)
