require "yaml"
require "fileutils"

Vagrant.require_version ">= 1.7.0"

CONFIG = File.expand_path("config.rb")
if File.exist?(CONFIG)
  require CONFIG
end

$os_image = (ENV['OS_IMAGE'] || "ubuntu16").to_sym

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
      config.vm.box = "bento/centos-7.2"
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

  (1..($master_count + $node_count)).each do |mid|
    name = (mid <= $node_count) ? $node_prefix : $master_prefix
    id   = (mid <= $node_count) ? mid : (mid - $node_count)

    config.vm.define "#{name}#{id}" do |n|
      n.vm.hostname = "#{name}#{id}"
      ip_addr = "#{$private_subnet}.#{$private_count}"
      n.vm.network :private_network, ip: "#{ip_addr}",  auto_config: true

      if $bridge_enable && $bridge_eth.to_s != ''
        n.vm.network "public_network", bridge: $bridge_eth
      end

      # Configure virtualbox provider
      n.vm.provider :virtualbox do |vb, override|
        vb.name = "#{$prefix_name}-#{n.vm.hostname}"
        set_vbox(vb, override)
      end

      # Configure libvirt provider
      n.vm.provider :libvirt do |lv, override|
        lv.host = "#{$prefix_name}-#{n.vm.hostname}"
        set_libvirt(lv, override)
      end
      $private_count += 1
    end
  end

  # Install of dependency packages using script
  config.vm.provision :shell, path: "./scripts/initial.sh"
end
