Vagrant.require_version ">= 1.7.0"

$os_image = (ENV['OS_IMAGE'] || "ubuntu16").to_sym
$master_count = (ENV['MASTERS'] || "1").to_i # The HA cluster at least 3 node.
$node_count = (ENV['NODES'] || "2").to_i
$system_vcpus = (ENV['CPU'] || "1").to_i
$system_memory = (ENV['MEMORY'] || "2048").to_i # Need more RAM(4G+), if ceph enable.
$bridge_enable = false
$bridge_eth = "eno1"
$private_subnet = "172.16.35"
$net_count = 10

Vagrant.configure("2") do |config|

  config.vm.provider "virtualbox"
  config.vm.provider "libvirt"

  # Set virtualbox func
  def set_vbox(vb, config)
    vb.gui = false
    vb.memory = $system_memory
    vb.cpus = $system_vcpus

    case $os_image
    when :centos7
      config.vm.box = "bento/centos-7.3"
    when :ubuntu16
      config.vm.box = "bento/ubuntu-16.04"
    end
  end

  # Set libvirt func
  def set_libvirt(lv, config)
    lv.nested = true
    lv.volume_cache = 'none'
    lv.uri = 'qemu+unix:///system'
    lv.memory = $system_memory
    lv.cpus = $system_vcpus

    case $os_image
    when :centos7
      config.vm.box = "centos/7"
    when :ubuntu16
      config.vm.box = "yk0/ubuntu-xenial"
    end
  end

  count = $net_count
  (1..($master_count + $node_count)).each do |mid|
    name = (mid <= $node_count) ? "node" : "master"
    id   = (mid <= $node_count) ? mid : (mid - $node_count)

    config.vm.define "#{name}#{id}" do |n|
      n.vm.hostname = "#{name}#{id}"
      ip_addr = "#{$private_subnet}.#{count}"
      n.vm.network :private_network, ip: "#{ip_addr}",  auto_config: true
      if $bridge_enable && $bridge_eth.to_s != ''
        n.vm.network "public_network", bridge: $bridge_eth
      end

      # Configure virtualbox provider
      n.vm.provider :virtualbox do |vb, override|
        vb.name = "kube-#{n.vm.hostname}"
        set_vbox(vb, override)
      end

      # Configure libvirt provider
      n.vm.provider :libvirt do |lv, override|
        lv.host = "kube-#{n.vm.hostname}"
        set_libvirt(lv, override)
      end
      count += 1

      n.vm.provision "shell", inline: "sudo swapoff -a"
      n.vm.provision "shell", inline: "sudo cp /vagrant/hosts /etc/"

      if mid == ($master_count + $node_count)
        config.vm.provision "cluster", type: "ansible" do |ansible|
          ansible.playbook = "cluster.yml"
          ansible.inventory_path = "inventory"
          ansible.limit = "all"
          ansible.host_key_checking = false
        end
      end
    end
  end
end
