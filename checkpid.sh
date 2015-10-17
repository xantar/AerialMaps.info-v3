#!/usr/bin/env bash

checkpid=$(cat "public/processing/$1/process.id")

ps -a | grep -v grep | grep $checkpid > /dev/null
exit $?
