#!/bin/bash
# Get vagrant config variable
function get_vagrant_config() {
cat <<EOF > get.rb
require "yaml";require "fileutils";
CONFIG = File.expand_path("config.rb")
require CONFIG
puts "#{\$${1}}"
EOF
ruby get.rb && rm get.rb
}

# Set inventory file
function set_inventory() {
local nodes="${SUBNET}.[${NET_COUNT}:$((${NET_COUNT}+${NODE_COUNT}-1))]"
local masters="${SUBNET}.[$((${NET_COUNT}+${NODE_COUNT})):$((${NET_COUNT}+${TOTAL}-1))]"
local master="${SUBNET}.$((${NET_COUNT}+${NODE_COUNT}+${MASTER_COUNT}-1))"

cat <<EOF > inventory
[etcd]
${masters}

[masters]
${masters}

[sslhost]
${master}

[nodes]
${nodes}
EOF
}

# Set hosts file
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

# Define variables
GROUP_VARS_PATH="./group_vars/all.yml"
FLANNEL_DEFAULT_PATH="./roles/networking/flannel/defaults/main.yml"
ETCD_DEFAULT_PATH="./roles/etcd/defaults/main.yml"
NODE_DEFAULT_PATH="./roles/kubernetes/node/defaults/main.yml"
VIP_DEFAULT_PATH="./roles/ha/defaults/main.yml"
INITIAL_SCRIPT_PATH="./scripts/initial.sh"

MASTER_COUNT=$(get_vagrant_config "master_count")
NODE_COUNT=$(get_vagrant_config "node_count")
SUBNET=$(get_vagrant_config "private_subnet")
NET_COUNT=$(get_vagrant_config "private_count")
MASTER_PREFIX=$(get_vagrant_config "master_prefix")
NODE_PREFIX=$(get_vagrant_config "node_prefix")
TOTAL=$((MASTER_COUNT+NODE_COUNT))
