
parse_traceroute <- function(target = "8.8.8.8", max_hops = 8, timeout_ms = 1000) { # nolint
  # Для Windows используем tracert
  if (.Platform$OS.type == "windows") {
    command <- sprintf("tracert -h %d -w %d %s",
                       max_hops, timeout_ms, target)
  } else {
    timeout_sec <- timeout_ms / 1000 # nolint
    command <- sprintf("traceroute -m %d -w %.1f %s",
                       max_hops, timeout_sec, target)
  }
  message("Running: ", command)
  tryCatch({
    output <- system(command, intern = TRUE, timeout = 30)
    hops <- data.frame(
      hop = integer(),
      ip = character(),
      latency_ms = numeric(),
      asn = character(),
      country = character(),
      latitude = numeric(),
      longitude = numeric(),
      city = character(),
      stringsAsFactors = FALSE
    )
    hop_number <- 1
    for (line in output) {
      if (grepl("^\\s*\\d+", line)) {
        # Извлекаем IP адрес
        ip_match <- regmatches(line,
          regexpr("\\b(?:[0-9]{1,3}\\.){3}[0-9]{1,3}\\b", line)) # nolint
        if (length(ip_match) > 0) {
          ip <- ip_match[1]
          # Извлекаем latency
          latency <- ifelse(
            grepl("ms", line),
            as.numeric(gsub(".*<\\s*(\\d+).*ms.*", "\\1", line)) %||% 0,
            0
          )
          # Определяем геолокацию по IP (упрощенно)
          geo_info <- get_ip_geolocation(ip)
          hops <- rbind(hops, data.frame(
            hop = hop_number,
            ip = ip,
            latency_ms = latency,
            asn = geo_info$asn,
            country = geo_info$country,
            latitude = geo_info$latitude,
            longitude = geo_info$longitude,
            city = geo_info$city,
            stringsAsFactors = FALSE
          ))
          hop_number <- hop_number + 1
        }
      }
    }
    if (nrow(hops) == 0) {
      message("No hops parsed. Returning example data.")
      return(create_example_route())
    }
    message("Parsed ", nrow(hops), " hops")
    return(hops)
  }, error = function(e) {
    message("Error: ", e$message)
    message("Returning example data")
    return(create_example_route()) # nolint
  })
}
get_ip_geolocation <- function(ip) {
  first_octet <- as.numeric(strsplit(ip, "\\.")[[1]][1])
  if (grepl("^192\\.168\\.", ip) || grepl("^10\\.", ip) || grepl("^172\\.", ip)) { # nolint
    # Частные IP
    return(list( # nolint
      asn = "AS?",
      country = "Local",
      city = "Local",
      latitude = 55.7558,  # Москва по умолчанию
      longitude = 37.6173
    ))
  } else if (first_octet == 8) {
    # Google IP range
    return(list( # nolint
      asn = "AS15169",
      country = "USA",
      city = "Mountain View",
      latitude = 37.3861,
      longitude = -122.0838
    ))
  } else if (first_octet >= 1 && first_octet <= 9) {
    # США
    return(list( # nolint
      asn = paste0("AS", 10000 + first_octet),
      country = "USA",
      city = "Unknown",
      latitude = 37.0902,
      longitude = -95.7129
    ))
  } else if (first_octet >= 80 && first_octet <= 95) {
    # Европа
    return(list( # nolint
      asn = paste0("AS", 20000 + first_octet),
      country = "EU",
      city = "Unknown",
      latitude = 50.8503,
      longitude = 4.3517
    ))
  } else if (first_octet >= 195 && first_octet <= 223) {
    # Россия/СНГ # nolint
    return(list( # nolint
      asn = paste0("AS", 30000 + first_octet),
      country = "Russia",
      city = "Moscow",
      latitude = 55.7558,
      longitude = 37.6173
    ))
  } else {
    # По умолчанию
    return(list( # nolint
      asn = "AS?",
      country = "Unknown",
      city = "Unknown",
      latitude = 0,
      longitude = 0
    ))
  }
}

#' Helper function: if null then
`%||%` <- function(x, y) if (!is.null(x) && !is.na(x)) x else y

#' Create example route data with all required columns
#' @export
create_example_route <- function() {
  data.frame(
    hop = 1:8,
    ip = c(
      "192.168.1.1", "10.0.0.1", "195.34.1.1", "217.150.1.1",
      "84.201.1.1", "87.245.1.1", "72.14.1.1", "8.8.8.8"
    ),
    latency_ms = c(1, 5, 15, 25, 40, 55, 75, 95),
    asn = c(
      "AS1234", "AS5678", "AS9101", "AS1121",
      "AS13238", "AS12389", "AS15169", "AS15169"
    ),
    country = c(
      "Local", "Local", "Russia", "Russia",
      "Netherlands", "UK", "USA", "USA"
    ),
    latitude = c(
      55.7558, 55.7558, 55.7558, 55.7558,
      52.3676, 51.5074, 37.3861, 37.3861
    ),
    longitude = c(
      37.6173, 37.6173, 37.6173, 37.6173,
      4.9041, -0.1278, -122.0838, -122.0838
    ),
    city = c(
      "Local", "Local", "Moscow", "Moscow",
      "Amsterdam", "London", "Mountain View", "Mountain View"
    ),
    stringsAsFactors = FALSE
  )
}