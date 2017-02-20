# Machine configuration variable
# examples : "bento/centos-7.2", "bento/ubuntu-16.04", "coreos-{alpha/beta/stable}"
$box_image       = "bento/centos-7.2"
$coreos_version  = "current"

$master_count    = 1
$node_count      = 2
$disk_count      = 0
$storage_path    = "./tmp/"
$storage_size    = "30720"

$system_memory   = 1024
$system_vcpus    = 1

$bridge_enable   = false
$bridge_eth      = "eno1"
$private_subnet  = "172.16.35"
$private_count   = 10

# Name prefix
$prefix_name   = "kube"
$master_prefix = "master"
$node_prefix   = "node"

# Virtualbox leave / Openstack change to OS default username:
# $ssh_user       = "vagrant"
# $ssh_keypath    = "~/.ssh/id_rsa"
# $ssh_port       = 22
