#FROM ubuntu:18.04
FROM ubuntu:22.04

###########################
#
#  OHJEET 
#
###############################

# buildaaminen
# sudo docker build -t garmin-map .

# ajaminen
# sudo docker run -v /home/antti/tmp:/ready_maps -i -t garmin-map /bin/sh
# ./generate_maps.sh



# Set up environment and renderer user
ENV TZ=Europe/Helsinki
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install packages
RUN apt-get --yes update && \
	apt-get install --yes apt-utils openjdk-8-jdk python3 osmosis wget git-core  \
	&& apt-get clean autoclean \
	&& apt-get autoremove --yes \
	&& rm -rf /var/lib/{apt,dpkg,cache,log}/

# ASENTAA bsdtar softan
RUN apt-get install --yes libarchive-tools


RUN mkdir /renderer
WORKDIR /renderer/

# RUN wget -nv http://osm.thkukuk.de/data/bounds-latest.zip -O bounds.zip
# RUN wget -nv http://osm.thkukuk.de/data/sea-latest.zip -O sea.zip
# RUN wget -nv http://download.geonames.org/export/dump/cities15000.zip -O cities.zip

# TESTAUS VAIHEESSA KOPSATAAN VALMIIT FIlEET
# wget  http://osm.thkukuk.de/data/bounds-latest.zip -O bounds.zip
# wget  http://osm.thkukuk.de/data/sea-latest.zip -O sea.zip
# wget  http://download.geonames.org/export/dump/cities15000.zip -O cities.zip

COPY bounds.zip /renderer/
COPY sea.zip /renderer/
COPY cities.zip /renderer/

# Install SPLITTER
RUN mkdir /renderer/download_splitter
WORKDIR /renderer/download_splitter
RUN wget -nv http://www.mkgmap.org.uk/download/splitter-r653.zip

# puretaan zip paketti siten, että yksi kerros hakemistorakenteesta tiputetaan pois
# niin ei tule ongelmia tuon hakemiston nimen kanssa.
# Alkuperäinen dockerfile ei toiminut ubuntu 22.04 kanssa
RUN bsdtar --strip-components=1 -xvf splitter*.zip
RUN cp splitter.jar ..
RUN cp -r lib ../splitter_lib
RUN rm -rf *




# # Install MKGMAPS
RUN mkdir /renderer/download_mkgmap
WORKDIR /renderer/download_mkgmap
RUN wget -nv http://www.mkgmap.org.uk/download/mkgmap-r4912.zip
RUN bsdtar --strip-components=1 -xvf mkgmap*.zip
RUN cp mkgmap.jar ../
RUN cp -r lib ../mkgmap_lib
# JOSTAIN SYYSTÄ EI SITTEN MILLÄÄN SUOSTU POISTAMAAN ROSKIA
#RUN rm -rf *



# move content from libs directories to common lib
WORKDIR /renderer
RUN mkdir /renderer/lib

# MOVE EI JOSTAIN SYYSTÄ ONNISTU?!?
RUN cp mkgmap_lib/* lib/
RUN cp splitter_lib/* lib/


# Configure stylesheets
ARG NOCACHE=0
RUN mkdir /renderer/styles
WORKDIR /renderer/styles
RUN git clone https://github.com/Myrtillus/Garmin_OSM_TK_map.git .

# JA JOSTAIN SYYSTÄ MOOVIT EI TAASKAAN TOIMI

RUN cp *.typ ..
RUN cp -r TK ..
RUN cp -r TK_pathsonly ..


RUN mkdir /osm-data


# testaus vaiheessa kopsataan valmis file
# wget  http://download.geofabrik.de/europe/finland-latest.osm.pbf
# wget  http://download.geofabrik.de/europe/spain/islas-baleares-latest.osm.pbf
# wget  http://download.geofabrik.de/europe/spain-latest.osm.pbf
COPY  finland-latest.osm.pbf /osm-data
COPY  islas-baleares-latest.osm.pbf /osm-data
COPY  spain-latest.osm.pbf /osm-data

RUN mkdir /ready_maps


WORKDIR /renderer

# Copy scripts
COPY --chown=renderer *.sh /renderer/
COPY --chown=renderer *.py /renderer/

# CMD /renderer/generate_maps.sh
