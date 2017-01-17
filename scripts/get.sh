#!/bin/bash
#
# Program: Get kubernetes po,svc component
# History: 2017/1/16 Kyle.b Release

NAMESPACE=${1:-"default"}

if [ ${NAMESPACE} == "all" ]; then
   kubectl get po,svc --all-namespaces -o wide
else
   kubectl get po,svc -o wide --namespace=${NAMESPACE}
fi
