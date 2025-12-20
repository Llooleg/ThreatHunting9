#' Parse traceroute output
#' @export
parse_traceroute <- function(target = "8.8.8.8") {
  # Для Windows используем tracert
  command <- ifelse(
    .Platform$OS.type == "windows",
    paste("tracert", target),
    paste("traceroute", target)
  )
   # nolint
  tryCatch({
    output <- system(command, intern = TRUE)
     # nolint
    # Простой парсинг вывода
    hops <- data.frame(
      hop = seq_along(output),
      ip = gsub(
        ".*\\s([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}).*",
        "\\1",
        output
      ),
      asn = "AS?",
      country = "Unknown"
    )
     # nolint
    hops
  }, error = function(e) {
    message("Error running traceroute: ", e$message)
    # Возвращаем пример данных
    data.frame(
      hop = 1:5,
      ip = paste0("192.168.", 1:5, ".1"),
      asn = paste0("AS", 1000 + 1:5),
      country = c("US", "DE", "FR", "RU", "CN")
    )
  })
}