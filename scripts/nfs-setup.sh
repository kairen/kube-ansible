#!/bin/bash
#
# Program: Setup NFS Server
#

set -e

sudo apt-get update
sudo apt-get -y install nfs-kernel-server

sudo mkdir -p /var/nfs/data

cat <<EOF > /etc/exports
/var/nfs/data *(rw,sync,no_root_squash,no_subtree_check)
EOF

sudo /etc/init.d/nfs-kernel-server restart
