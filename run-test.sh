#!/bin/bash

i=1;
while :; do
   echo "${i}: $(curl -I 172.16.35.10 2>/dev/null | head -n 1)";
   i=$((i+1));
   sleep 1;
done
