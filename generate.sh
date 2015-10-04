#!/bin/bash

MAP=$1
CAM=$2
>&2 echo $1
cd public
cp images/map_correcting.png photos/development/maps/$MAP.png
cp images/map_correcting.png photos/development/maps/"$MAP"_20.png
cd processing
rm -rf $MAP
mkdir $MAP
>&2 echo '------------------------------------'
>&2 echo "  Starting Lens Profile Correction Lens: $CAM"
>&2 echo '------------------------------------'

#Handle different Cameras

if [ $CAM == 1 ] ; then
  rawtherapee -o $MAP -p ../RTProfiles/DJI-P2.pp3 -c ../photos/development/unproc/$MAP
else
  #This is the default for an unknown camera, Dont apply a lens profile or process.
  cp ../photos/development/unproc/$MAP/*.jpg  $MAP/
  cp ../photos/development/unproc/$MAP/*.JPG  $MAP/
fi

>&2 echo '------------------------------------'
>&2 echo '     Finished Lens Correction'
>&2 echo '------------------------------------'

cd $MAP
rename 'y/A-Z/a-z/' *
>&2 echo '------------------------------------'
>&2 echo '           Starting Mosaic'
>&2 echo '------------------------------------'
../../../buildmosaic.sh jpg multirow $MAP
>&2 echo '------------------------------------'
>&2 echo '           Finished Mosaic'
>&2 echo '------------------------------------'

cp output.png ../../photos/development/maps/$MAP.png
cp output_20.png ../../photos/development/maps/"$MAP"_20.png
