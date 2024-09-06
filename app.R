
#

library(shiny)
library(leaflet)
library(tidyverse)
library(sf)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("MNO Water Sampling Sites"),

    #map
    leafletOutput("mymap", height="800px")
              
    
)

# Define server logic required to draw interactive map
server <- function(input, output, session) {
  
  sites <- read.csv("allSites.csv")  
  sites$Region<- as.factor(sites$Region)
  
  wshed <- sf::read_sf("./watersheds/ONT_WSHED_BDRY_TERT_DERIVED.shp")
  wshed <- st_transform(wshed, "+proj=longlat +datum=WGS84")
  
  tlua <- sf::read_sf("./TLU/TRADITIONAL_LAND_USE_AREA.shp")
  tlua <- st_transform(tlua, "+proj=longlat +datum=WGS84")
  
  sigeco <- sf::read_sf("./SIGECO/SIGNIFICANT_ECOLOGICAL_AREA.shp")
  sigeco <- st_transform(sigeco, "+proj=longlat +datum=WGS84")
  
  
  sites_wq <- sites |> filter(sites$Type == "wq")
  sites_bf <- sites |> filter(sites$Type == "baitfish")
  sites_edna <- sites |> filter(sites$Type == "eDNA")
  sites_obbn <- sites |> filter(sites$Type == "OBBN")
  
  marker_wq <- makeAwesomeIcon(
    markerColor = "darkblue",
    iconColor= "white",
    text = ~Site
  )
  
  marker_bf <- makeAwesomeIcon(
    markerColor = "darkblue",
    iconColor = "yellow",
    text = ~Site
  )
  
  marker_edna <- makeAwesomeIcon(
    markerColor = "darkgreen",
    iconColor = "white",
    text = ~Site
  )
  
  marker_obbn <- makeAwesomeIcon(
    markerColor = "darkred",
    iconColor = "white",
    text = ~Site
  )
  
  
  output$mymap <- renderLeaflet({
    leaflet() %>%
        setView(lng = -81.44, 
                lat = 48.20, 
                zoom = 5) |> 
      addProviderTiles("Stadia.Outdoors", group = "Stadia Outdoors") |>
      addProviderTiles("CartoDB.Positron", group = "Positron (minimal)")  |> 
      addTiles(urlTemplate = "https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}", group = "Google Hybrid") |>
      
      addPolygons(data=wshed, group = "Watersheds (Tertiary)", label = ~NAME, fillOpacity = 0.005, weight=1, highlightOptions = highlightOptions(weight=3)) |>
      
      addPolygons(data=tlua, group = "Trad. Land Use Area", label = ~SUBTYPE, fillOpacity = 0.1, weight=1, color="#ed5a69",  highlightOptions = highlightOptions(weight=3)) |>
      
      addPolygons(data=tlua, group = "Sig. Ecol. Areas", label = ~SUBTYPE, fillOpacity = 0.1, weight=1, color="#ae1eb0",  highlightOptions = highlightOptions(weight=3)) |>
      
      addAwesomeMarkers(data = sites_wq, 
                        icon = marker_wq,
                        lng= ~Long, 
                        lat=~Lat, 
                        label = ~Name,
                        group = "Water quality") |>
      addAwesomeMarkers(data = sites_bf, 
                        icon = marker_bf,              
                        lng= ~Long, 
                        lat=~Lat, 
                        label = ~Name,
                        group = "baitfish") |>
      addAwesomeMarkers(data = sites_edna, 
                        icon = marker_edna,
                        lng= ~Long, 
                        lat=~Lat, 
                        label = ~Name,
                        group = "eDNA") |>
      addAwesomeMarkers(data = sites_obbn, 
                        icon = marker_obbn,             
                        lng= ~Long, 
                        lat=~Lat, 
                        label = ~Name,
                        group = "OBBN") |>
       addLayersControl(
        baseGroups = c(
          "Stadia Outdoors (default)",
          "Positron (minimal)",
          "Google Hybrid"
        ),
        overlayGroups = c("Water quality", "baitfish", "eDNA", "OBBN","Watersheds (Tertiary)","Trad. Land Use", "Sig. Ecol. Areas"),
        options = layersControlOptions()
    )})
}


# Run the application 
shinyApp(ui = ui, server = server)
