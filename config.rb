## Machine Configuration
$box_image      = "bento/ubuntu-14.04"
$master_count   = 1
$node_count     = 1
$disk_count     = 1
$storage_path   = "./tmp/"
$storage_size   = "30720"

$system_memory  = 1024
$system_vcpus   = 1

$bridge_enable  = true
$bridge_eth     = "eno1"

# Ansible Declarations:
#$number_etcd       = "kube[1:2]"
#$number_master     = "kube[1:2]"
#$number_worker     = "kube[1:3]"
$kube_masters      = "kube1"
$kube_workers = "kube[2:4]"
$kube_control      = "kube1"

# Virtualbox leave / Openstack change to OS default username:
$ssh_user       = "vagrant"
$ssh_keypath    = "~/.ssh/id_rsa"
$ssh_port       = 22

# Ansible Details:
$ansible_limit     = "all"
$ansible_playbook  = "halcyon-kubernetes/kube-deploy/kube-deploy.yml"
$ansible_inventory = ".vagrant/provisioners/ansible/inventory_override"
