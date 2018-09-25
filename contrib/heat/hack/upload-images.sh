#!/bin/bash
#
# Upload cloud images to glance.
#

set -eu

# upload ubuntu 16.04 python image 
openstack image create "ubuntu-16.04-server" \
  --file ubuntu-16.04-server.qcow2 \
  --disk-format qcow2 \
  --container-format bare \
  --public
