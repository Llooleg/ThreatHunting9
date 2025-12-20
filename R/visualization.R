
create_network_map <- function(routing_data) {
   # nolint
  m <- leaflet::leaflet() %>% # nolint
    leaflet::addTiles() %>%
    leaflet::addCircleMarkers(
      lng = routing_data$longitude,
      lat = routing_data$latitude,
      popup = paste(
        "ASN:", routing_data$asn,
        "<br>Country:", routing_data$country
      ),
      radius = 6,
      color = "red"
    )
   # nolint
  m
}