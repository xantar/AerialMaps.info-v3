#!/usr/bin/env bash

##############################
###  Author: Paul Benson
###    Date: 10/18/2015
###
### Checks the process.id file in the directory of a map being processed and Kills that PID
###
###   Usage: killpid.sh [map_id]
### Example: killpid.sh 1
##############################

checkpid=$(cat "public/processing/$1/process.id")

kill $checkpid -n
exit $?
