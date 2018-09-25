#!/bin/bash
#
# Build cloud images for Heat Kubernetes.
#

set -eu

if [ ! -f ".env/" ];
  virtualenv .env
fi

.env/bin/activate
pip install diskimage-builder

export DIB_RELEASE=xenial
# export ELEMENTS_PATH=./elements

# build image using diskimage-builder
disk-image-create -a amd64 -o ubuntu-16.04-server vm ubuntu -p python
