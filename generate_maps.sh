#!/bin/bash

function create_map () {
	# Extract region out of Finland OSM file
	#osmosis --read-pbf file=/osm-data/data.osm.pbf --bounding-box left=$1 bottom=$2 right=$3 top=$4 --write-pbf region.osm.pbf
	osmosis --read-pbf file=${11} --bounding-box left=$1 bottom=$2 right=$3 top=$4 --write-pbf region.osm.pbf

	echo "splitteri ajossa ........................................."


	# Split the osm file to smaller pieces
	java -Xmx4000m -jar splitter.jar region.osm.pbf\
	--description="$6"\
	--precomp-sea=sea.zip\
	--geonames-file=cities.zip\
	--max-areas=4096\
	--max-nodes=1000000\
	--mapid=${9}\
	--status-freq=2\
	--keep-complete=true

	# Fix the names in the template.args file descriptions, MAX 20 CHARACTERS
	python3 fix_names.py $8


	echo "mkgmap ajossa  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

	# Create the gmapsupp map file, NOTE THE MAPNAME HAS TO BE UNIQUE, FAMILY ID IS ALSO UNIQUE
	java -Xmx6000m -jar mkgmap.jar\
	--max-jobs=7\
	--gmapsupp\
	--latin1\
	--tdbfile\
	--mapname=${9}\
	--description="$8"\
	--family-id=8888\
	--product-id=1\
	--series-name="OSM MTB Suomi"\
	--family-name="OSM MTB Suomi"\
	--area-name="OSM MTB Suomi"\
	--style-file=$5/ \
	--cycle-map\
	--precomp-sea=sea.zip\
	--generate-sea\
	--bounds=bounds.zip\
	--remove-ovm-work-files\
	-c template.args \
	$7.typ 

	# copy the map file to folder that is mapped to local host
	mv gmapsupp.img /ready_maps/${10}

	# Clean the directory
	rm -f  osmmap.* *.img *.pbf osmmap_license.txt template* densities* areas*
}



cd /renderer

create_map 22.80 61.00 25.00 62.20 TK "Tampere region" TK_Tampere_v2 TK_TRE 88880002 tk_tre2.img "/osm-data/finland-latest.osm.pbf"

create_map 1.5 37 4 42 TK "Mallorca region" TK_Tampere_v2 TK_Mallorca 88950008 mallorca.img "/osm-data/islas-baleares-latest.osm.pbf"

#create_map 21.00 59.75 31.60 70.08 TK "Finland" TK_Tampere_v2 TK_Finland 88940007 tk_finland.img "/osm-data/finland-latest.osm.pbf"

#create_map 1.28 38.24 4.5 40.65 TK "Mallorca region" TK_Tampere_v2 TK_Mallorca 88950008 mallorca.img "/osm-data/spain-latest.osm.pbf"



