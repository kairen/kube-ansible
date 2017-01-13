#!/bin/bash

set -xe

sudo yum install -y gcc git vim openssl-devel expect \
                    python python-devel python-setuptools

sudo easy_install pip
sudo pip install  ansible

sudo su -

expect -c "
spawn ssh-keygen -t rsa  \"\"
expect \"Enter passphrase (empty for no passphrase):\"
send \"\r\"
expect \"Enter same passphrase again:\"
send \"\r\"
"

cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

git clone https://github.com/kairen/kubernetes-ceph-ansible.git -b dev
