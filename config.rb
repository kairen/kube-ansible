# The HA-cluster at least 3 node.
$master_count = 1
$node_count = 2

# If enable 'ceph-cluster', the memory need more than 2048MB.
$system_memory = 1024
$system_vcpus = 1

$bridge_enable = false
$bridge_eth = "eno1"
$private_subnet = "172.16.35"
$private_count = 10

# Name prefix
$prefix_name = "kube"
$master_prefix = "master"
$node_prefix = "node"
