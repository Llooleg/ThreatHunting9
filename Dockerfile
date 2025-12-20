# Используем базовый образ с R и Shiny
FROM r-base:4.3.0

# Установим системные утилиты (traceroute для Linux)
RUN apt-get update && apt-get install -y \
    traceroute \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Создаем директорию приложения
WORKDIR /app

# Копируем весь проект
COPY . .

# Устанавливаем R зависимости
RUN R -e "install.packages(c('shiny', 'leaflet', 'httr', 'dplyr', 'jsonlite'))"

# Устанавливаем наш пакет
RUN R -e "devtools::install('/app')"

# Копируем Shiny приложение в правильную директорию
RUN cp -r inst/shinyapp /srv/shiny-server/THREATHUNTING9

# Открываем порт
EXPOSE 3838

# Команда запуска
CMD ["/usr/bin/shiny-server"]