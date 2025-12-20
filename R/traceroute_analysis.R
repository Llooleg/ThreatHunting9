
parse_traceroute <- function(target = "8.8.8.8") {
  # Для Windows используем tracert
  command <- ifelse(.Platform$OS.type == "windows", 
                   paste("tracert", target),
                   paste("traceroute", target))
  
  tryCatch({
    output <- system(command, intern = TRUE)
    
    # Простой парсинг вывода
    hops <- data.frame(
      hop = 1:length(output),
      ip = gsub(".*\\s([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}).*", "\\1", output),
      asn = "AS?",
      country = "Unknown"
    )
    
    return(hops)
  }, error = function(e) {
    message("Error running traceroute: ", e$message)
    # Возвращаем пример данных
    return(data.frame(
      hop = 1:5,
      ip = paste0("192.168.", 1:5, ".1"),
      asn = paste0("AS", 1000 + 1:5),
      country = c("US", "DE", "FR", "RU", "CN")
    ))
  })
}