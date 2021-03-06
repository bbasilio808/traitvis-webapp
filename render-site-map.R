library(rgeos)
library(dplyr)

# render leaflet map from traits for a given date
render_site_map <- function(traits, render_date, legend_title) {

  # get most recent traits for each site
  latest_traits <- subset(traits, date <= render_date & !is.na(geometry)) %>% 
    group_by(geometry) %>% top_n(1, date)

  pal <- colorNumeric(
    palette = 'Greens',
    domain = traits[[ 'mean' ]]
  )
  
  map <- leaflet(options = leafletOptions(minZoom = 18, maxZoom = 21))  %>% 
    addProviderTiles(providers$Esri.WorldImagery) 
  # eventually want to overlay with stitched image from current day
  # see /data/terraref/sites/ua-mac/Level_1/fullfield/
  # see addRasterImage https://rstudio.github.io/leaflet/raster.html

  # add polygon for each site, color by trait mean value
  if (nrow(latest_traits) > 0) {
    for (i in 1:nrow(latest_traits)){
      curr_trait <- latest_traits[i,]
      
      site_poly <- readWKT(curr_trait[[ 'geometry' ]])
  
      if ('polygons' %in% names(attributes(site_poly))) {
        trait_value <- curr_trait[[ 'mean' ]]
        map <- addPolygons(map, data = site_poly, 
                           color = pal(trait_value), opacity = 0, 
                           fillColor = pal(trait_value), fillOpacity = 0.8)
                           #TODO add popup = plot name + trait value for plot 
      }
    }
  }
  
  map <- addLegend(map, "bottomright", pal = pal, 
                   title = legend_title,
                   values = traits[[ 'mean' ]])
  map
}
