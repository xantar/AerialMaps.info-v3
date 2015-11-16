#!/usr/bin/env bash

##############################
###  Author: Paul Benson
###    Date: 10/18/2015
###
### Rotates Original Map and creates 2 output files and replaces map
###
###   Usage: rotate.sh [map_id] [degrees]
### Example: rotate.sh 1 45
##############################

# Arguements

#Map ID
MAP=$1

#Rotate X Degrees
ROT=$2

# Compression for Convert
# "None", "BZip", "Fax", "Group4", "JPEG", "JPEG2000", "Lossless", "LZW", "RLE", or "Zip"
COMP="LZW"

# Color Depth for Convert
DEPTH=8

# Thumbnail Width
TWIDTH=600

echo "Rotating Map $MAP $ROT degrees"
pwd
cd public
pwd
cd processing
pwd
cd $MAP
pwd

# Store the PID in $MAP/process.id
echo $$ > $MAP/process.id
echo "98" > $MAP/process.status
#################### Step 1: Rotate & Recomplress Final Map ####################
convert ./output.tif -compress $COMP -depth $DEPTH -rotate $ROT -transparent white ./output.png

if [ $? == 0 ]; then
  echo "8" > $MAP/process.status
else
  echo "99" > $MAP/process.status
  exit $?
fi

convert ./output.png -resize $TWIDTH output_20.png

#################### Step 2: Copy Final Images ####################
cp output.png ../../photos/maps/$MAP.png
cp output_20.png ../../photos/maps/"$MAP"_20.png

echo "Rotate Complete"
