## Machine configuration variable
# Can use "bento/ubuntu-14.04" or "bento/centos-7.2" box.
$box_image       = "bento/ubuntu-14.04"
$master_count    = 1
$node_count      = 3
$disk_count      = 0
$storage_path    = "./tmp/"
$storage_size    = "30720"

$system_memory   = 1024
$system_vcpus    = 1

$bridge_enable   = true
$bridge_eth      = "eno1"
$private_subnet  = "172.16.35"
$private_count   = 10

## Hostname prefix
$master_prefix = "master"
$node_prefix   = "node"

## Ansible Declarations:
$kube_masters    = "master[1:#{$master_count}]"
$kube_workers    = "node[1:#{$node_count}]"

## Ansible inventory variable
$enable_ansible      = true
$ansible_playboos    = "./kube-deploy/kube-deploy.yml"

$ansible_groups   = {
    "kube-masters" => [$kube_masters],
    "kube-workers" => [$kube_workers],
    "kube-control" => [$kube_masters],
    "kube-cluster:children" => ["kube-masters", "kube-workers"],
}

# $ansible_groups   = {
#     "etcd" => [$kube_masters],
#     "masters" => [$kube_masters],
#     "sslhost" => [$kube_masters],
#     "node" => [$kube_workers],
# }

## Virtualbox leave / Openstack change to OS default username:
# $ssh_user       = "vagrant"
# $ssh_keypath    = "~/.ssh/id_rsa"
# $ssh_port       = 22
