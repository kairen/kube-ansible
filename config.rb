# Machine configuration variable
# examples : "bento/centos-7.2", "bento/ubuntu-16.04", "coreos-{alpha/beta/stable}"
$box_image = "bento/ubuntu-16.04"
$coreos_version = "current"

$master_count = 1 # The HA-cluster at least 3 node.
$node_count = 2
$disk_count = 0
$storage_path = "./tmp/"
$storage_size = "20480"

$system_memory = 1024 # If enable 'ceph-cluster', the memory need more than 2048MB.
$system_vcpus = 1

$bridge_enable = false
$bridge_eth = "eno1"
$private_subnet = "172.16.35"
$private_count = 10

# Name prefix
$prefix_name = "kube"
$master_prefix = "master"
$node_prefix = "node"
