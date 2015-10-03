#!/bin/bash

ARG1=$1
ARG2=$2
>&2 echo $1

cd public
cp images/map_processing.png photos/development/maps/$1.png
cp images/map_processing.png photos/development/maps/"$1"_20.png
cd processing
rm -rf $1
mkdir $1
>&2 echo '------------------------------------'
>&2 echo '  Starting Lens Profile Correction'
>&2 echo '------------------------------------'
rawtherapee -o $1 -p ../RTProfiles/DJI-P2.pp3 -c ../photos/development/unproc/$1
>&2 echo '------------------------------------'
>&2 echo '     Finished Lens Correction'
>&2 echo '------------------------------------'

cd $1
>&2 echo '------------------------------------'
>&2 echo '           Starting Mosaic'
>&2 echo '------------------------------------'
../../../buildmosaic.sh jpg multirow
>&2 echo '------------------------------------'
>&2 echo '           Finished Mosaic'
>&2 echo '------------------------------------'

cp output.png ../../photos/development/maps/$1.png
cp output_20.png ../../photos/development/maps/"$1"_20.png
