#!/usr/bin/env bash

##############################
###  Author: Paul Benson
###    Date: 10/18/2015
###
### Checks the process.id file in the directory of a map being processed and returns true if the PID is running
###
###   Usage: checkpid.sh [map_id]
### Example: checkpid.sh 1
##############################

checkpid=$(cat "public/processing/$1/process.id")

ps -a | grep -v grep | grep $checkpid > /dev/null
exit $?
