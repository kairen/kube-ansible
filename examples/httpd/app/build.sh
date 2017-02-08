#!/bin/bash

if [ -z ${1} ]; then
   echo "Input version number."
   exit 1
fi

docker build -t "kyle/web-app:${1}" .
