#!/bin/bash

############################################
###  Author: Paul Benson
###    Date: 10/18/2015
###
### Created for aerialmaps.info
#############################################

### Command Line Arguements
#   Usage: generate.sh [Map ID] [Camera ID] [Mapping Method] [Bearing]
# Example: generate.sh 1 1 prealigned 142.05

# Map ID
MAP=$1

# Camera
CAM=$2

# Mapping Method
MET=$3

# Bearing Rotation
ROT=$4

### Settings

# File Type (lower and upper case)
FT="jpg"
UFT="JPG"

# Compression for Nona TIFFs
# "NONE", "PACKBITS","LZW", "DEFLATE"
COMP="LZW"

# Compression for Enblend
# "deflate", "jpeg", "lzw", "none", "packbits"
COMP2="JPEG"

# Compression for Convert
# "None", "BZip", "Fax", "Group4", "JPEG", "JPEG2000", "Lossless", "LZW", "RLE", or "Zip"
COMP3="LZW"

# Field of View
FOV=5

# Color Depth
DEPTH=8

# Thumbnail Width
TWIDTH=600

# Control Point Settings
MINMATCH=20

#Seive 1
S1W=30
S1H=30

#Seive 2
S2W=15
S2H=15

# The script starts in ./ (The root directory of the Rails App)
cd public
echo "0" > $MAP/process.status

#################### Step 1: Lens correction ####################

# Set the temporary image for the Map Project to Correcting
cp images/map_correcting.png photos/maps/$MAP.png
cp images/map_correcting.png photos/maps/"$MAP"_20.png

cd processing
mv $MAP/image.order ./$MAP.order
rm -rf $MAP
mkdir $MAP
mv $MAP.order $MAP/image.order

# Store the PID in $MAP/process.id
echo $$ > $MAP/process.id
echo "1" > $MAP/process.status

echo " Generating Map:"
echo "       Lens: $CAM       Map: $MAP"
echo "    Mapping: $MET   Bearing: $ROT"

echo '------------------------------------'
echo "  Starting Lens Profile Correction"
echo '------------------------------------'

# Handle Camera Lens Profiles
# Current Camera(s) Supported:
# 1 - DJI Phantom FC200 (Phantom 2 Vision & Vision +)

if [ $CAM == 1 ] ; then
  echo '1 - DJI Phantom FC200 (Phantom 2 Vision & Vision +)'
  rawtherapee -o $MAP -p ../RTProfiles/DJI-P2.pp3 -c ../photos/unproc/$MAP
 
  ## Check exit status, if error then exit ##
  if [ $? == 0 ]; then
    echo "2" > $MAP/process.status
  else
    exit $?
  fi
  
else
  echo "Lens $CAM - unknown Camera, Skipping Lens Correction"
  #This is the default for an unknown camera, Dont apply a lens profile or process.
  cp ../photos/unproc/$MAP/*.$UFT  $MAP/
  cp ../photos/unproc/$MAP/*.$FT  $MAP/
  echo "2" > $MAP/process.status
fi

echo '------------------------------------'
echo '      Finished Lens Correction'
echo '------------------------------------'

cd $MAP

# Rename all to lowercase
rename 'y/A-Z/a-z/' *

echo '------------------------------------'
echo '           Starting Mosaic'
echo '------------------------------------'

# Generate Image Order
ls -v ./*.$FT > ./auto.order
#Image Count
IMGC=`ls -l ./*.$FT | wc -l`

# Generate Project File

if [ -e ./image.order ] ; then
  /usr/bin/pto_gen -o ./map.pto -f $FOV -p 0 `cat ./image.order`;
else
  /usr/bin/pto_gen -o ./map.pto -f $FOV -p 0 `cat ./auto.order`;
fi

#################### Step 2: Control Point Generation ####################

# Set the temporary image for the Map Project to Control Point Generation
cp ../../images/map_generating.png ../../photos/maps/$MAP.png
cp ../../images/map_generating.png ../../photos/maps/"$MAP"_20.png

sleep 1
if [ $MET == prealigned ] ; then
  /usr/bin/cpfind -n 1 --prealigned --minmatches $MINMATCH --sieve1width=$S1W --sieve1height=$S1H --sieve2width=$S2W --sieve2width=$S2H -o ./map.pto ./map.pto
elif [ $MET == multirow ]; then
  /usr/bin/cpfind -n 1 --multirow --minmatches $MINMATCH --sieve1width=$S1W --sieve1height=$S1H --sieve2width=$S2W --sieve2width=$S2H -o ./map.pto ./map.pto
else
  /usr/bin/cpfind --linearmatch --minmatches $MINMATCH --sieve1width=$S1W --sieve1height=$S1H --sieve2width=$S2W --sieve2width=$S2H -o ./map.pto ./map.pto
fi

## Check exit status, if error then exit ##
if [ $? == 0 ]; then
  echo "3" > process.status
else
  exit $?
fi

#################### Step 2: Control Point Optimization ####################

# Set the temporary image for the Map Project to Control Point Optomization
cp ../../images/map_optomising.png ../../photos/maps/$MAP.png
cp ../../images/map_optomising.png ../../photos/maps/"$MAP"_20.png

sleep 1
### Run AutoOptimiser
#Usage:  autooptimiser [options] input.pto
#   To read a project from stdio, specify - as input file.
#
#  Options:
#     -o file.pto  output file. If obmitted, stdout is used.
#
#    Optimisation options (if not specified, no optimisation takes place)
#     -a       auto align mode, includes various optimisation stages, depending
#               on the amount and distribution of the control points
#     -p       pairwise optimisation of yaw, pitch and roll, starting from
#              first image
#     -m       Optimise photometric parameters
#     -n       Optimize parameters specified in script file (like PTOptimizer)
#
#    Postprocessing options:
#     -l       level horizon (works best for horizontal panos)
#     -s       automatically select a suitable output projection and size
#    Other options:
#     -q       quiet operation (no progress is reported)
#     -v HFOV  specify horizontal field of view of input images.
#               Used if the .pto file contains invalid HFOV values
#               (autopano-SIFT writes .pto files with invalid HFOV)
#
#   When using -a -l -m and -s options together, a similar operation to the "Align"
#    button in hugin is performed.
###

/usr/bin/autooptimiser -p -a -n -m -o ./map.pto ./map.pto

## Check exit status, if error then exit ##
if [ $? == 0 ]; then
  echo "4" > process.status
else
  exit $?
fi

sleep 1
### Run Pano_Modify to set projection to 0 and Center the Panorama
#Usage:  pano_modify [options] input.pto
#
#  Options:
#     -o, --output=file.pto  Output Hugin PTO file. Default: <filename>_mod.pto
#     -p, --projection=x     Sets the output projection to number x
#     --fov=AUTO|HFOV|HFOVxVFOV   Sets field of view
#                                   AUTO: calculates optimal fov
#                                   HFOV|HFOVxVFOV: set to given fov
#     -s, --straighten       Straightens the panorama
#     -c, --center           Centers the panorama
#     --canvas=AUTO|num%|WIDTHxHEIGHT  Sets the output canvas size
#                                   AUTO: calculate optimal canvas size
#                                   num%: scales the optimal size by given percent
#                                   WIDTHxHEIGHT: set to given size
#     --crop=AUTO|AUTOHDR|left,right,top,bottom  Sets the crop rectangle
#                                   AUTO: autocrop panorama
#                                   AUTOHDR: autocrop HDR panorama
#                                   left,right,top,bottom: to given size
#     -h, --help             Shows this help
###
/usr/bin/pano_modify --projection=0 -c -o ./map.pto ./map.pto

## Check exit status, if error then exit ##
if [ $? == 0 ]; then
  echo "5" > process.status
else
  exit $?
fi

sleep 1
### Run Nona 
# The following output formats (n option of panotools p script line)
# are supported:
#
#  JPG, TIFF, PNG  : Single image formats without feathered blending:
#  TIFF_m          : multiple tiff files
#  TIFF_multilayer : Multilayer tiff files, readable by The Gimp 2.0
#
#Usage: nona [options] -o output project_file (image files)
#  Options: 
#      -c         create coordinate images (only TIFF_m output)
#      -v         quiet, do not output progress indicators
#      -t num     number of threads to be used (default: nr of available cores)
#      -g         perform image remapping on the GPU
#
#  The following options can be used to override settings in the project file:
#      -i num     remap only image with number num
#                   (can be specified multiple times)
#      -m str     set output file format (TIFF, TIFF_m, TIFF_multilayer, EXR, EXR_m)
#      -r ldr/hdr set output mode.
#                   ldr  keep original bit depth and response
#                   hdr  merge to hdr
#      -e exposure set exposure for ldr mode
#      -p TYPE    pixel type of the output. Can be one of:
#                  UINT8   8 bit unsigned integer
#                  UINT16  16 bit unsigned integer
#                  INT16   16 bit signed integer
#                  UINT32  32 bit unsigned integer
#                  INT32   32 bit signed integer
#                  FLOAT   32 bit floating point
#      -z         set compression type.
#                  Possible options for tiff output:
#                   NONE      no compression
#                   PACKBITS  packbits compression
#                   LZW       lzw compression
#                   DEFLATE   deflate compression
###
/usr/bin/nona -z $COMP -m TIFF_m -o ./map_ map.pto

## Check exit status, if error then exit ##
if [ $? == 0 ]; then
  echo "6" > process.status
else
  exit $?
fi

#################### Step 3: Blending Images ####################

# Set the temporary image for the Map Project to Blending Images
cp ../../images/map_combining.png ../../photos/maps/$MAP.png
cp ../../images/map_combining.png ../../photos/maps/"$MAP"_20.png

echo "Blending $IMGC Images:"

sleep 1
### Run Enblend
#Usage: enblend [options] [--output=IMAGE] INPUT...
#Blend INPUT images into a single IMAGE.
#
#INPUT... are image filenames or response filenames.  Response
#filenames start with an "@" character.
#
#Common options:
#  -V, --version          output version information and exit
#  -a                     pre-assemble non-overlapping images
#  -h, --help             print this help message and exit
#  -l, --levels=LEVELS    limit number of blending LEVELS to use (1 to 29);
#                         negative number of LEVELS decreases maximum;
#                         "auto" restores the default automatic maximization
#  -o, --output=FILE      write output to FILE; default: "a.tif"
#  -v, --verbose[=LEVEL]  verbosely report progress; repeat to
#                         increase verbosity or directly set to LEVEL
#  -w, --wrap[=MODE]      wrap around image boundary, where MODE is "none",
#                         "horizontal", "vertical", or "both"; default: none;
#                         without argument the option selects horizontal wrapping
#  -x                     checkpoint partial results
#  --compression=COMPRESSION
#                         set compression of output image to COMPRESSION,
#                         where COMPRESSION is:
#                         "deflate", "jpeg", "lzw", "none", "packbits", for TIFF files and
#                         0 to 100, or "jpeg", "jpeg-arith" for JPEG files,
#                         where "jpeg" and "jpeg-arith" accept a compression level
#  --layer-selector=ALGORITHM
#                         set the layer selector ALGORITHM;
#                         default: "all-layers"; available algorithms are:
#                         "all-layers": select all layers in all images;
#                         "first-layer": select only first layer in each multi-layer image;
#                         "largest-layer": select largest layer in each multi-layer image;
#                         "no-layer": do not select any layer from any image;
#  --parameter=KEY1[=VALUE1][:KEY2[=VALUE2][:...]]
#                         set one or more KEY-VALUE pairs
#
#Extended options:
#  -b BLOCKSIZE           image cache BLOCKSIZE in kilobytes; default: 2048KB
#  -c, --ciecam           use CIECAM02 to blend colors; disable with
#                         "--no-ciecam"
#  --fallback-profile=PROFILE-FILE
#                         use the ICC profile from PROFILE-FILE instead of sRGB
#  -d, --depth=DEPTH      set the number of bits per channel of the output
#                         image, where DEPTH is "8", "16", "32", "r32", or "r64"
#  -g                     associated-alpha hack for Gimp (before version 2)
#                         and Cinepaint
#  --gpu                  use graphics card to accelerate seam-line optimization
#  -f WIDTHxHEIGHT[+xXOFFSET+yYOFFSET]
#                         manually set the size and position of the output
#                         image; useful for cropped and shifted input
#                         TIFF images, such as those produced by Nona
#  -m CACHESIZE           set image CACHESIZE in megabytes; default: 1024MB
#
#Mask generation options:
#  --primary-seam-generator=ALGORITHM
#                         use main seam finder ALGORITHM, where ALGORITHM is
#                         "nearest-feature-transform" or "graph-cut";
#                         default: "nearest-feature-transform"
#  --image-difference=ALGORITHM[:LUMINANCE-WEIGHT[:CHROMINANCE-WEIGHT]]
#                         use ALGORITHM for calculation of the difference image,
#                         where ALGORITHM is "max-hue-luminance" or "delta-e";
#                         LUMINANCE-WEIGHT and CHROMINANCE-WEIGHT define the weights
#                         of lightness and color; default: delta-e:1: 1
#  --coarse-mask[=FACTOR] shrink overlap regions by FACTOR to speedup mask
#                         generation; this is the default; if omitted FACTOR
#                         defaults to 8
#  --fine-mask            generate mask at full image resolution; use e.g.
#                         if overlap regions are very narrow
#  --smooth-difference=RADIUS    (deprecated)
#                         smooth the difference image prior to seam-line
#                         optimization with a Gaussian blur of RADIUS;
#                         default: 0 pixels
#  --optimize             turn on mask optimization; this is the default
#  --no-optimize          turn off mask optimization
#  --optimizer-weights=DISTANCE-WEIGHT[:MISMATCH-WEIGHT]
#                         set the optimizer's weigths for distance and mismatch;
#                         default: 8:1
#  --mask-vectorize=LENGTH
#                         set LENGTH of single seam segment; append "%" for
#                         relative value; defaults: 4 for coarse masks and
#                         20 for fine masks
#  --anneal=TAU[:DELTAE-MAX[:DELTAE-MIN[:K-MAX]]]
#                         set annealing parameters of optimizer strategy 1;
#                         defaults: 0.75:7000:5:32
#  --dijkstra=RADIUS      set search RADIUS of optimizer strategy 2; default:
#                         25 pixels
#  --save-masks[=TEMPLATE]
#                         save generated masks in TEMPLATE; default: "mask-%n.tif";
#                         conversion chars: "%i": mask index, "%n": mask number,
#                         "%p": full path, "%d": dirname, "%b": basename,
#                         "%f": filename, "%e": extension; lowercase characters
#                         refer to input images uppercase to the output image
#  --load-masks[=TEMPLATE]
#                         use existing masks in TEMPLATE instead of generating
#                         them; same template characters as "--save-masks";
#                         default: "mask-%n.tif"
#  --visualize[=TEMPLATE] save results of optimizer in TEMPLATE; same template
#                         characters as "--save-masks"; default: "vis-%n.tif"
###
enblend --compression=$COMP2 -d $DEPTH --wrap=NONE --fine-mask -a -o ./map.tif ./map_*.tif

## Check exit status, if error then exit ##
if [ $? == 0 ]; then
  echo "7" > process.status
else
  exit $?
fi

### Run Convert

#################### Step 4: Compress Final Map ####################
convert ./map.tif -trim ./output.tif

## Check exit status, if error then exit ##
if [ $? == 0 ]; then
  echo "8" > process.status
else
  exit $?
fi

convert ./output.tif -compress $COMP3 -depth $DEPTH -rotate $ROT -transparent white ./output.png
convert ./output.png -resize $TWIDTH output_20.png

#################### Step 5: Copy Final Images ####################
cp output.png ../../photos/maps/$MAP.png
cp output_20.png ../../photos/maps/"$MAP"_20.png


