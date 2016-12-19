## Machine configuration variable
# Can use "bento/ubuntu-14.04" or "bento/centos-7.2" box.
$box_image       = "bento/centos-7.2"
$master_count    = 2
$node_count      = 2
$disk_count      = 1
$storage_path    = "./tmp/"
$storage_size    = "30720"

$system_memory   = 1024
$system_vcpus    = 1

$bridge_enable   = false
$bridge_eth      = "eno1"
$private_subnet  = "172.16.35"
$private_count   = 10

## Ansible Declarations:
$kube_masters      = "master[1:#{$master_count}]"
$kube_workers = "node[1:#{$node_count}]"
$kube_control      = "master[1:#{$master_count}]"

## Ansible inventory variable


## Virtualbox leave / Openstack change to OS default username:
# $ssh_user       = "vagrant"
# $ssh_keypath    = "~/.ssh/id_rsa"
# $ssh_port       = 22
