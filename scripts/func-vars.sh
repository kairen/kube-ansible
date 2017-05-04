#!/bin/bash
#
# Program: Vagrant func and vars
# History: 2017/1/19 Kyle.b Release

# Get vagrant config variable
function get_vagrant_config() {
  grep -i "^\$${1}" config.rb | awk '{ print $3 }' | sed 's/\"//g'
}

# Replace vagrant config
function vagrant_config() {
  perl -i -pe "s/${1}\s*=\s*\d*/${1} = ${2}/g" config.rb
}

# Replace roles defaults variable
function role_config() {
  perl -i -pe "s/${1}/${2}/g" ${3}
}

# Create inventory file
function set_inventory() {
  local nodes="${SUBNET}.[${NET_COUNT}:$((${NET_COUNT}+${NODE_COUNT}-1))]"
  local masters="${SUBNET}.[$((${NET_COUNT}+${NODE_COUNT})):$((${NET_COUNT}+${TOTAL}-1))]"
  local master="${SUBNET}.$((${NET_COUNT}+${NODE_COUNT}+${MASTER_COUNT}-1))"
  rm -f inventory
  for group in "etcd" "masters" "sslhost" "nodes" "cluster:children"; do
    echo "[${group}]" >> inventory
    if [ ${group} == "nodes" ]; then
      echo -e "${nodes}\n" >> inventory
    elif [ ${group} == "cluster:children" ]; then
      echo -e "masters\nnodes" >> inventory
    else
      echo -e "${masters}\n" >> inventory
    fi
  done
}

# Create hosts file
function set_hosts() {

cat <<EOF > hosts
127.0.0.1   localhost
::1         localhost
EOF

for ((i=0; i<${TOTAL}; i++)) do
  PREFIX=""
  if [ ${i} -lt ${NODE_COUNT} ]; then
    PREFIX="${NODE_PREFIX}$((${i}+1))"
  else
    PREFIX="${MASTER_PREFIX}$((${i}+1-${NODE_COUNT}))"
  fi
  echo "${SUBNET}.$((${NET_COUNT}+${i})) ${PREFIX}" >> hosts
done
}

# Check is number
function isnum() {
  re='^[0-9]+$'
  if ! [[ ${1} =~ ${re} ]] ; then
    echo "Error: Not a number." >&2; exit 1
  fi
}

# Define variables
GROUP_VARS_PATH="./group_vars/all.yml"
FLANNEL_DEFAULT_PATH="./roles/networking/flannel/defaults/main.yml"
ETCD_DEFAULT_PATH="./roles/etcd/defaults/main.yml"
NODE_DEFAULT_PATH="./roles/kubernetes/node/defaults/main.yml"
VIP_DEFAULT_PATH="./roles/kubernetes/ha/defaults/main.yml"
INITIAL_SCRIPT_PATH="./scripts/initial.sh"

MASTER_COUNT=$(get_vagrant_config "master_count")
NODE_COUNT=$(get_vagrant_config "node_count")
SUBNET=$(get_vagrant_config "private_subnet")
NET_COUNT=$(get_vagrant_config "private_count")
MASTER_PREFIX=$(get_vagrant_config "master_prefix")
NODE_PREFIX=$(get_vagrant_config "node_prefix")
TOTAL=$((MASTER_COUNT+NODE_COUNT))

HOSTS=""
for ((i=0; i<${TOTAL}; i++)) do
  HOSTS="${HOSTS} ${SUBNET}.$((${NET_COUNT}+${i}))"
done
