#!/bin/bash

###
### AerialMaps.info
### Paul Benson 2015
###
###
### Based on a script by 
### Jon-Pierre Stoermer 04-01-2012 (DroneMapper.com)
###

###
### Command Line Args
###
### File Type
ARG1=$1

### Compression
ARG2="JPEG"

### Color Depth
ARG3=8

## Matching Method 'linearmatch' or 'multirow'
ARG4=$2

## Map ID
MAP=$3

## Generate Order
ls -v ./*.$ARG1 > ./order_auto.out

###
### FHOV = 360 / # Of Images
###
IMGC=`ls -l ./*.$ARG1 | wc -l`

### Generate Project

  /usr/bin/pto_gen -o ./project.pto -f 10 -p 0 `cat ./order_auto.out`;

### Generate Control Points
cp ../../images/map_generating.png ../../photos/development/maps/$MAP.png
cp ../../images/map_generating.png ../../photos/development/maps/"$MAP"_20.png

sleep 1
if [ $ARG4 == prealigned ] ; then
  /usr/bin/cpfind -n 1 --prealigned --minmatches 20 --sieve1width=20 --sieve1height=20 --sieve2width=10 --sieve2width=10 -o ./project.pto ./project.pto
elif [ $ARG4 == multirow ]; then
  /usr/bin/cpfind -n 1 --multirow --minmatches 20 --sieve1width=20 --sieve1height=20 --sieve2width=10 --sieve2width=10 -o ./project.pto ./project.pto
else
  /usr/bin/cpfind --linearmatch --minmatches 20 --sieve1width=20 --sieve1height=20 --sieve2width=10 --sieve2width=10 -o .
fi

### Optimiser
cp ../../images/map_optomising.png ../../photos/development/maps/$MAP.png
cp ../../images/map_optomising.png ../../photos/development/maps/"$MAP"_20.png
sleep 1
/usr/bin/autooptimiser -p -a -n -o ./project.pto ./project.pto

sleep 1
/usr/bin/pano_modify --projection=0 -c -o ./project.pto ./project.pto

### Nona
sleep 1
/usr/bin/nona -z $ARG2 -m TIFF_m -o ./project_ project.pto

echo "IMG Count: " $IMGC

### Enblend
cp ../../images/map_combining.png ../../photos/development/maps/$MAP.png
cp ../../images/map_combining.png ../../photos/development/maps/"$MAP"_20.png

sleep 1
enblend --compression=$ARG2 -d $ARG3 --wrap=NONE --fine-mask -a -o ./project5m.tif ./project_*.tif

convert ./project5m.tif -trim ./output.tif
convert ./output.tif -compress $ARG2 -depth $ARG3 -transparent white ./output.png
convert ./output.png -resize 600 output_20.png

