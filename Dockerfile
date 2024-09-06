# Base R Shiny image
FROM rocker/shiny-verse:latest

# Install required libraries
RUN apt-get -y update && \
    apt-get install -y  libudunits2-dev libgdal-dev libgeos-dev libproj-dev

# Make a directory in the container
RUN mkdir /home/shiny-app

# Install R dependencies
RUN R -e "install.packages(c('geos','gdal', 'proj','sf', 'leaflet'))"

#Set workdir
WORKDIR /home/shiny-app

# Copy the Shiny app code
COPY app.R /home/shiny-app/app.R
COPY allSites.csv /home/shiny-app/allSites.csv
COPY watersheds /home/shiny-app/watersheds
COPY TLU /home/shiny-app/TLU
COPY SIGECO /home/shiny-app/SIGECO

# Expose the application port
EXPOSE 3838

# Run the R Shiny app
CMD ["R", "-e", "shiny::runApp('/home/shiny-app/app.R', host='0.0.0.0', port=3838)"]