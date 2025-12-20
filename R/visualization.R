
#' Create network map visualization
#' @export
create_network_map <- function(routing_data) {
  library(leaflet)
  
  m <- leaflet() %>%
    addTiles() %>%
    addCircleMarkers(
      lng = routing_data$longitude,
      lat = routing_data$latitude,
      popup = paste("ASN:", routing_data$asn, "<br>Country:", routing_data$country),
      radius = 6,
      color = "red"
    )
  
  return(m)
}