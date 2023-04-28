# This map is one of the results of the AHRC project Prismatic Jane Eyre.
## It has been coded by Giovanni Pietro Vitali (Paris-Saclay University) with 
## Matthew Reynolds (University of Oxford), who is the PI of the project.
## Last update 5 December 2021

# Call the libraries
library(leaflet)
library(sp)
library(rgdal)
library(RColorBrewer)
library(leaflet.extras)
library(leaflet.minicharts)
library(htmlwidgets)
library(raster)
library(mapview)
library(leafem)
library(geojsonio)
library(viridis)
library(ggplot2)

## upload the data in Geojson and define the palette
countries <- geojsonio::geojson_read("data/geojson/countries.geojson", what = "sp")

## upload the data in csv
data <- read.csv("data/csv/pje_2023_04_28.csv")

## Create a new dataset jittering the coordinates
data$lat <- jitter(data$lat, factor = 1, amount = 0.1)
data$lng <- jitter(data$lng, factor = 1, amount = 0.1)

write.csv(data, "data/csv/pje_2023_04_28_jittered.csv")

## Attribute the new values to data variable
data <- read.csv("data/csv/pje_2023_04_28_jittered.csv")

## Create the palette based on the table field date
pal <- colorNumeric(
  palette = "Reds",
  domain = data$date,
  reverse = FALSE)

  ## Create the map object
  m <- leaflet(countries) %>% 

    
    ## Basemap
    addProviderTiles(providers$OpenStreetMap)  %>% 
 
    ## Set the central view and zoom
    setView(lng = 20.80, 
            lat = 25.98, 
            zoom = 1 ) %>%
    
    ## add a layer of polygons according to the places in which editions are spreaded
    addPolygons(data = countries, 
                color =	"#008000", 
                weight = 0.5, 
                smoothFactor = 0.5,
                group = "Countries",
                label = ~paste(countries$titles, ": ", countries$annotation, "act(s) of translations"))%>%
    
    ## Add circle markers of Acts of translations colored accordig to the years 
    addCircleMarkers(data = data,
                     lng = ~lng,
                     lat = ~lat,
                     fillColor = ~pal(date),
                     fillOpacity = 0.7,
                     radius = 6,
                     stroke = TRUE,
                     weight = 1,
                     color = "black",
                     group = "Acts of Translation",
                     popup = ~paste("<b>", label_place_of_publication, "</b>" ,"<br>", "<br>",
                                    "Language:", "<b>", language,"</b>","<br>",
                                    "Title:", "<b>", title, "</b>", "</b>","<br>",
                                    "Translator:", "<b>", translator_s, "</b>","<br>",
                                    "Date:", "<b>", date, "</b>", "<br>",
                                    "Publisher:", "<b>", publisher, "</b>", "<br>",
                                    "Country:", "<b>", country,"</b>","<br>",
                                    "Known reprints & re-editions in the same place:", "<b>", dates_of_reprints, "</b>", "<br>",
                                    "Notes:", "<b>", notes, "</b>", "<br>",
                                    sep = " ")) %>%
    
    ## add the legend of the several editions
    addLegend("bottomleft", pal = pal, values = data$date,
              title = "Year",
              labFormat = labelFormat(suffix = "0", 
                                      big.mark = ",",
                                      transform = function(x) 0.1 * x),
              opacity = 1) %>%
    
    ## Add Heatmap of the  dataset
    addHeatmap(data = data,
               lng = ~lng,
               lat = ~lat, 
               group = "Heatmap of Translation Activity",
               blur = 8, 
               max = 0.5, 
               radius = 10) %>%
    
  
  ## add a topright legend
   addLegend("topright", 
              
              colors = c("trasparent"),
              
              labels=c("www.prismaticjaneeyre.org"),
              
              title="Prismatic Jane Eyre") %>%
    
    ## Add a minimap to orient the user in zoom mode
    addMiniMap() %>%
    
    ## Add a zoom reset button
    addResetMapButton() %>%
    
    ## Add a layers control tool
    addLayersControl(overlayGroups = c("Countries", 
                                       "Acts of Translation", 
                                       "Heatmap of Translation Activity"),
                    options = layersControlOptions(collapsed = TRUE)) %>%
                    
                    hideGroup("Heatmap of Translation Activity")
                   
  ## Run the map
  m
  
  