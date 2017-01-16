#!/bin/bash

i=1

while :; do
    echo "${i}. $(curl -s -o /dev/null \
                       -w "%{http_code}" \
                       172.16.35.12:30000)"
    i=$((i+1))
    sleep 2
done
