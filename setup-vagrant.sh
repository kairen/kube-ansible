#!/bin/bash
#
# Program: Setup a vagrant env
# History: 2017/1/19 Kyle.b Release

set -e
source ./scripts/func-vars.sh

# Prepare config file
HOSTS=""
for ((i=0; i<${TOTAL}; i++)) do
    HOSTS="${HOSTS} ${SUBNET}.$((${NET_COUNT}+${i}))"
done

perl -i -pe "s/flannel_opts: \"\"/flannel_opts: --iface=${BIND_ETH}/g" ${GROUP_VARS_PATH}
perl -i -pe "s/${SUBNET}.[0-9]*/${SUBNET}.$((${NET_COUNT}+${NODE_COUNT}))/g" ${GROUP_VARS_PATH}
perl -i -pe "s/HOSTS=\".*\"/HOSTS=\"${HOSTS}\"/g" ${INITIAL_SCRIPT_PATH}
perl -i -pe "s/${MASTER_PREFIX}[0-9]*/${MASTER_PREFIX}${MASTER_COUNT}/g" ${INITIAL_SCRIPT_PATH}

# Create inventory
set_inventory
set_hosts

# Run vagrant
vagrant up
