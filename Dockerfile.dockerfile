FROM rocker/shiny:latest
COPY . /home/app
RUN R -e "install.packages(c('shiny', 'leaflet', 'httr'))"
EXPOSE 3838
CMD ["R", "-e", "shiny::runApp('/home/app/inst/shinyapp', port=3838, host='0.0.0.0')"]