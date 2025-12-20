
parse_traceroute <- function(output) {
  # Простой парсер
  lines <- strsplit(output, "\n")[[1]]
  hops <- data.frame(hop = 1:length(lines), ip = lines) # nolint
  return(hops)
}