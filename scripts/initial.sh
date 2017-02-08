#!/bin/bash

set -e
HOST_NAME=$(hostname)

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

HOSTS="172.16.35.10 172.16.35.11 172.16.35.12"
for host in ${HOSTS}; do
    # Create dir
    sudo sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@${host} "sudo mkdir -p /root/.ssh"
    # Write authorized_keys file
    sudo cat /root/.ssh/id_rsa.pub | \
         sudo sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@${host} "sudo tee /root/.ssh/authorized_keys"
done

# Run ansible-playbook
sudo mv /home/vagrant/kubernetes-ceph-ansible /root/

cd /root/kubernetes-ceph-ansible
sudo ansible-playbook -i inventory cluster-site.yml

WAIT_MES="The connection to the server localhost:8080 was refused - did you specify the right host or port?"
echo -n -e "\nWait for API server start ....\n"
while [ "$(kubectl get node 2>&1)" == "${WAIT_MES}" ]; do sleep 1; done
WAIT_MES="No resources found."
while [ "$(kubectl get node 2>&1)" == "${WAIT_MES}" ]; do sleep 1; done

echo "Deploying addons ..."
sudo ansible-playbook -i inventory addons-site.yml

else
sudo rm -r /home/vagrant/kubernetes-ceph-ansible
fi
