FROM mcr.microsoft.com/openjdk/jdk:21-ubuntu

# install git, wget, and unzip
RUN apt-get update && \
    apt-get install -y git wget unzip maven && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/graphhopper/graphhopper
WORKDIR /graphhopper

# Download GTFS data and OSM data, then build the project
RUN wget -O gtfs.zip https://data.samtrafiken.se/trafiklab/gtfs-sverige-2/2025/04/sweden-20250406.zip && \
    wget https://download.geofabrik.de/europe/sweden-latest.osm.pbf && \
    mvn clean package -DskipTests

# Copy the configuration file
COPY config.yml config.yml
RUN mkdir -p /data
VOLUME [ "/data" ]
RUN sed -i '/^ *bind_host/s/^ */&# /p' config.yml

EXPOSE 8989 8990

# The following process will take roughly 5 minutes on a modern laptop when it is executed for the first time.
# It imports the previously downloaded OSM data as well as the GTFS.
CMD ["java", "-Xmx8g", "-jar", "web/target/graphhopper-web-11.0-SNAPSHOT.jar", "server", "config.yml"]
