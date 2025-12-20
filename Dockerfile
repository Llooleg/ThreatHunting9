# Используем более легкий образ
#FROM r-base:4.3.0
FROM rocker/shiny:4.3.0

# Установим системные утилиты
RUN apt-get update && apt-get install -y \
    traceroute \
    iputils-ping \
    net-tools \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Установим R пакеты
RUN R -e "install.packages(c('shiny', 'ggplot2', 'dplyr'))"

# Рабочая директория
WORKDIR /app

# Копируем код
COPY . .

# Порт для Shiny
EXPOSE 3838

# Команда по умолчанию
CMD ["R", "-e", "shiny::runApp('/app', port=3838, host='0.0.0.0')"]

