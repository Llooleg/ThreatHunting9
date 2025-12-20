
create_map <- function(data) {
  leaflet() %>% # nolint
    addTiles() %>% # nolint
    addMarkers(lng = 37.6, lat = 55.7, popup = "Moscow") # nolint
}