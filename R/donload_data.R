
download_ip_data <- function(source = "dbip") {
  if (source == "dbip") {
    message("Downloading DB-IP data...")
    # Скачиваем пример файла
    url <- "https://download.db-ip.com/free/dbip-country-lite-2024-01.csv.gz"
    download.file(url, "data-raw/dbip.csv.gz")
  } else {
    message("MaxMind requires registration")
  }
}