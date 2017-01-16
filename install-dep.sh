#!/bin/bash

HOST_NAME=$(hostname)
HOSTS="172.16.35.10 172.16.35.11"

if [ ${HOST_NAME} == "master1" ]; then

set -xe

# Install packages
sudo yum install -y gcc git vim openssl-devel \
                    python python-devel python-setuptools

sudo easy_install pip
sudo pip install  ansible
sudo rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/sshpass-1.05-1.el6.x86_64.rpm

#
yes "/root/.ssh/id_rsa" | sudo ssh-keygen -t rsa -N ""

for host in ${HOSTS}; do
    # Create dir
    sudo sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@${host} "sudo mkdir /root/.ssh"
    # Write authorized_keys file
    sudo cat /root/.ssh/id_rsa.pub | \
         sudo sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@${host} "sudo tee /root/.ssh/authorized_keys"
done

sudo cat /root/.ssh/id_rsa.pub | sudo tee /root/.ssh/authorized_keys

sudo mv /home/vagrant/kubernetes-ceph-ansible /root/

else

sudo rm -r /home/vagrant/kubernetes-ceph-ansible

fi
