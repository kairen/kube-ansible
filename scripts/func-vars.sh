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

# Define variables
BIND_ETH="enp0s8"
GROUP_VARS_PATH="./group_vars/all.yml"
ETCD_DEFAULT_PATH="./roles/etcd/defaults/main.yml"
NODE_DEFAULT_PATH="./roles/node/defaults/main.yml"
INITIAL_SCRIPT_PATH="./scripts/initial.sh"

MASTER_COUNT=$(get_vagrant_config "master_count")
NODE_COUNT=$(get_vagrant_config "node_count")
SUBNET=$(get_vagrant_config "private_subnet")
NET_COUNT=$(get_vagrant_config "private_count")
MASTER_PREFIX=$(get_vagrant_config "master_prefix")
TOTAL=$((MASTER_COUNT+NODE_COUNT))
