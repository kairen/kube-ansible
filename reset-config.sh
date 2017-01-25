#!/bin/bash
#
# Program: Reset all config
# History: 2017/1/25 Kyle.b Release

set -e
source ./scripts/func-vars.sh

# Replace of variables
perl -i -pe "s/flannel_opts: --iface=${BIND_ETH}/flannel_opts: \"\"/g" ${GROUP_VARS_PATH}
perl -i -pe "s/${SUBNET}.[0-9]*/${SUBNET}.12/g" ${GROUP_VARS_PATH}
perl -i -pe "s/${BIND_ETH}/{{ ansible_default_ipv4.interface }}/g" ${ETCD_DEFAULT_PATH}
perl -i -pe "s/${BIND_ETH}/{{ ansible_default_ipv4.interface }}/g" ${NODE_DEFAULT_PATH}
perl -i -pe "s/HOSTS=\".*\"/HOSTS=\"${SUBNET}.10 ${SUBNET}.11 ${SUBNET}.12\"/g" ${INITIAL_SCRIPT_PATH}

cat <<EOF > inventory
[etcd]
172.16.35.12

[masters]
172.16.35.12

[sslhost]
172.16.35.12

[node]
172.16.35.[10:11]
EOF
