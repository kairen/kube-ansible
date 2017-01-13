#!/bin/bash

HOST_NAME=$(hostname)

if [ ${HOST_NAME} == "master1" ]; then

set -xe

sudo yum install -y gcc git vim openssl-devel expect \
                    python python-devel python-setuptools

sudo easy_install pip
sudo pip install  ansible

sudo mv /home/vagrant/kubernetes-ceph-ansible /root/
else

sudo rm -r /home/vagrant/kubernetes-ceph-ansible

fi
