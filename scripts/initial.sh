#!/bin/bash
#
# Program: Initial vagrant.
# History: 2017/1/16 Kyle.b Release

set -e
HOST_NAME=$(hostname)
OS_NAME=$(awk -F= '/^NAME/{print $2}' /etc/os-release | grep -o "\w*"| head -n 1)
DEPLOY_KUBE=true

if [ ${HOST_NAME} == "master1" ]; then
  case "${OS_NAME}" in
    "CentOS")
      sudo yum install -y epel-release
      sudo yum install -y git ansible sshpass python-netaddr openssl-devel
    ;;
    "Ubuntu")
      sudo sed -i 's/us.archive.ubuntu.com/tw.archive.ubuntu.com/g' /etc/apt/sources.list
      sudo apt-add-repository -y ppa:ansible/ansible
      sudo apt-get update && sudo apt-get install -y ansible git sshpass python-netaddr libssl-dev
    ;;
    *)
      echo "${OS_NAME} is not support ..."; exit 1
  esac

  # Create ssh key
  yes "/root/.ssh/id_rsa" | sudo ssh-keygen -t rsa -N ""

  HOSTS="172.16.35.10 172.16.35.11 172.16.35.12"
  for host in ${HOSTS}; do
    sudo sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@${host} "sudo mkdir -p /root/.ssh"
    sudo cat /root/.ssh/id_rsa.pub | \
         sudo sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@${host} "sudo tee /root/.ssh/authorized_keys"
  done

  # Move file to destination
  sudo cp /vagrant/hosts /etc/

  if ${DEPLOY_KUBE}; then
    cd /vagrant
    sudo ansible-playbook -i inventory cluster.yml

    WAIT_MES="The connection to the server localhost:8080 was refused - did you specify the right host or port?"
    echo -n -e "\nWait for API server start ....\n"
    while [ "$(kubectl get node 2>&1)" == "${WAIT_MES}" ]; do sleep 1; done
    WAIT_MES="No resources found."
    while [ "$(kubectl get node 2>&1)" == "${WAIT_MES}" ]; do sleep 1; done

    echo "Deploying addons ..."
    sudo ansible-playbook -i inventory addons.yml
  fi
else
  sudo cp /vagrant/hosts /etc/
fi
