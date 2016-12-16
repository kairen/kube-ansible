#!/usr/bin/env bash

sed -i 's/us.archive.ubuntu.com/tw.archive.ubuntu.com/g' /etc/apt/sources.list
curl -sSL https://get.docker.com/ | sh
apt-get install -y openvswitch-switch bridge-utils git
gpasswd -a vagrant docker
