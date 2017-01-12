#!/bin/bash

set -xe

sudo yum install -y gcc git vim openssl-devel \
                    python python-devel python-setuptools

sudo easy_install pip
sudo pip install  ansible

git clone https://github.com/kairen/kubernetes-ceph-ansible.git -b dev
