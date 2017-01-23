#!/bin/bash

set -xe

HOST_NAME=$(hostname)
HOSTS="172.16.35.10 172.16.35.11"

if [ ${HOST_NAME} == "master1" ]; then

# Install packages
OS_NAME=$(awk -F= '/^NAME/{print $2}' /etc/os-release | grep -o "\w*" | head -n 1)
case "${OS_NAME}" in
    "CentOS")
    sudo yum install -y gcc git vim openssl-devel \
                        python python-devel python-setuptools

    sudo rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/sshpass-1.05-1.el6.x86_64.rpm

    ;;
    "Ubuntu")
    sudo sed -i 's/us.archive.ubuntu.com/tw.archive.ubuntu.com/g' /etc/apt/sources.list
    sudo apt-get update
    sudo apt-get install -y python-dev python-setuptools \
                            libssl-dev git gcc sshpass
    ;;
    *)
    echo "${OS_NAME} is not support ..."
    exit 1
esac

sudo easy_install pip
sudo pip install  ansible

# Create ssh key
yes "/root/.ssh/id_rsa" | sudo ssh-keygen -t rsa -N ""

# for host in ${HOSTS}; do
#     # Create dir
#     sudo sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@${host} "sudo mkdir /root/.ssh"
#     # Write authorized_keys file
#     sudo cat /root/.ssh/id_rsa.pub | \
#          sudo sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@${host} "sudo tee /root/.ssh/authorized_keys"
# done

sudo cat /root/.ssh/id_rsa.pub | sudo tee /root/.ssh/authorized_keys
sudo mv /home/vagrant/kubernetes-ceph-ansible /root/

else

sudo rm -r /home/vagrant/kubernetes-ceph-ansible

fi
