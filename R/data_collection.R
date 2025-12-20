
download_geolocation <- function(source = "dbip") {
  if (!dir.exists("data-raw")) {
    dir.create("data-raw", recursive = TRUE)
  }
  # Создаем уникальное имя файла на основе источника
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  dest <- paste0("data-raw/", source, "_geolocation_", timestamp, ".csv")
  # Генерируем реалистичные примерные данные
  set.seed(123)  # Для воспроизводимости
  if (source == "dbip") {
    # Примерные данные в формате DB-IP
    data <- data.frame(
      ip_start = c(
        "1.0.0.0", "2.0.0.0", "3.0.0.0", "8.8.8.0",  # nolint
        "10.0.0.0", "172.16.0.0", "192.168.0.0"
      ),
      ip_end = c(
        "1.255.255.255", "2.255.255.255", "3.255.255.255", "8.8.8.255",
        "10.255.255.255", "172.31.255.255", "192.168.255.255"
      ),
      country_code = c("US", "RU", "CN", "US", "PRIVATE", "PRIVATE", "PRIVATE"),
      country_name = c(
        "United States", "Russia", "China", "United States",
        "Private Network", "Private Network", "Private Network"
      ),
      region = c("California", "Moscow", "Beijing", "California", NA, NA, NA),
      city = c("Los Angeles", "Moscow", "Beijing", "Mountain View", NA, NA, NA),
      latitude = c(34.0522, 55.7558, 39.9042, 37.3861, NA, NA, NA),
      longitude = c(-118.2437, 37.6173, 116.4074, -122.0838, NA, NA, NA),
      asn = c("AS13335", "AS12389", "AS4134", "AS15169", NA, NA, NA),
      as_name = c(
        "CLOUDFLARENET", "ROSTELECOM", "CHINANET-BACKBONE",
        "GOOGLE", NA, NA, NA
      )
    )
    message("Created example DB-IP geolocation data")
  } else if (source == "maxmind") {
    # Примерные данные в формате MaxMind
    data <- data.frame(
      network = c(
        "1.0.0.0/24", "2.0.0.0/16", "8.8.8.0/24",
        "10.0.0.0/8", "192.168.0.0/16"
      ),
      geoname_id = c(5375481, 524901, 5375481, NA, NA),
      registered_country_geoname_id = c(6252001, 2017370, 6252001, NA, NA),
      represented_country_geoname_id = c(NA, NA, NA, NA, NA),
      is_anonymous_proxy = c(0, 0, 0, 1, 1),
      is_satellite_provider = c(0, 0, 0, 0, 0),
      postal_code = c("90001", "101000", "94043", NA, NA),
      latitude = c(34.0522, 55.7558, 37.3861, NA, NA),
      longitude = c(-118.2437, 37.6173, -122.0838, NA, NA),
      accuracy_radius = c(1000, 50, 100, NA, NA)
    )
    message("Created example MaxMind geolocation data")
    message("Note: Real MaxMind data requires API registration")
  } else {
    stop("Source must be 'dbip' or 'maxmind'")
  }
  # Сохраняем данные
  write.csv(data, dest, row.names = FALSE)
  message("Data saved to: ", dest)
  message("Records created: ", nrow(data))
  return(dest)
}

process_geolocation <- function(file_path) {
  if (!file.exists(file_path)) {
    stop("File not found: ", file_path)
  }
  # Читаем данные
  data <- read.csv(file_path, stringsAsFactors = FALSE)
  message("Processing file: ", basename(file_path))
  message("Total records: ", nrow(data))
  # Стандартизируем выходные данные
  if ("ip_start" %in% names(data) && "ip_end" %in% names(data)) {
    # DB-IP формат
    result <- data.frame(
      ip_range = paste0(data$ip_start, " - ", data$ip_end),
      country = data$country_name,
      country_code = data$country_code,
      asn = data$asn,
      as_name = data$as_name,
      city = data$city,
      latitude = data$latitude,
      longitude = data$longitude,
      source = "DB-IP"
    )
  } else if ("network" %in% names(data)) {
    # MaxMind формат
    result <- data.frame(
      ip_range = data$network,
      country = ifelse(
        data$is_anonymous_proxy == 1,
        "Private Network",
        ifelse(!is.na(data$latitude), "United States", "Unknown")
      ),
      country_code = ifelse(data$is_anonymous_proxy == 1, "PRIVATE", "US"),
      asn = NA,
      as_name = NA,
      city = NA,
      latitude = data$latitude,
      longitude = data$longitude,
      source = "MaxMind"
    )
  } else {
    # Неизвестный формат - возвращаем как есть
    warning("Unknown data format. Returning raw data.")
    result <- data
    result$source <- "Unknown"
  }
  # Убираем строки с NA в критических полях
  result <- result[!is.na(result$latitude) & !is.na(result$longitude), ]
  message("Valid records with coordinates: ", nrow(result))
  return(result) # nolint
}