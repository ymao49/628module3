library(leaflet)
library(ggradar)
library(ggplot2)

business <- read.csv('business.csv')
business$business_id <- as.character(business$business_id)
review <- read.csv('review_split.csv')
review$business_id <- as.character(review$business_id)
rad <- read.csv('rad_points.csv')
rad$business_id <- as.character(rad$business_id)
suggestions <- read.csv('suggestions.csv')
suggestions$suggestion <- as.character(suggestions$suggestion)

# /Users/pinecone/Desktop/WISC/628/Module3/yelp_review/
