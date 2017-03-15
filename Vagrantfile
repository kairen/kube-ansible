require "yaml"
require "fileutils"

Vagrant.require_version ">= 1.7.0"

CONFIG = File.expand_path("config.rb")
if File.exist?(CONFIG)
  require CONFIG
end

Vagrant.configure("2") do |config|
  config.vm.box = $box_image
  cores_prefixs = $box_image.split("-")
  if cores_prefixs[0] == 'coreos'
    config.vm.box_url = "https://storage.googleapis.com/%s.release.core-os.net/amd64-usr/%s/coreos_production_vagrant.json" % [cores_prefixs[1], $coreos_version]
  end

  ## Setting bridge network and vm infos
  if $bridge_enable && $bridge_eth.to_s != ''
    config.vm.network "public_network", bridge: $bridge_eth
  end

  config.vm.provider "virtualbox" do |vm|
    vm.memory = $system_memory
    vm.cpus = $system_vcpus
  end

  machine_total = $master_count + $node_count
  ## Configuration of machines
  (1..machine_total).each do |machine_id|
    name = (machine_id <= $node_count) ? $node_prefix : $master_prefix
    id   = (machine_id <= $node_count) ? machine_id : (machine_id - $node_count)

    config.vm.define "#{name}#{id}" do |subconfig|
      subconfig.vm.hostname = "#{name}#{id}"
      subconfig.vm.provider "virtualbox" do |vm|
        vm.name = "#{$prefix_name}-#{subconfig.vm.hostname}"
      end
	  ip_addr = "#{$private_subnet}.#{$private_count}"
      subconfig.vm.network "private_network", ip: "#{ip_addr}",  auto_config: true
      $private_count += 1

      ## Create extra disk at nodes
      if machine_id <= $node_count
        (1..$disk_count).each do |disk_id|
          subconfig.vm.provider "virtualbox" do |vm|
            vm.customize ["createhd", "--filename", "#{$storage_path}n#{id}d#{disk_id}", "--size", $storage_size]
            vm.customize [
                "storageattach", :id,
                "--storagectl", "SATA Controller",
                "--port", "#{disk_id}",
                "--type", "hdd",
                "--medium", "#{$storage_path}n#{id}d#{disk_id}.vdi"]
          end
        end
      end
    end
  end

  # Install of dependency packages using script
  config.vm.provision "file", source: "../kube-ansible", destination: "~/"
  config.vm.provision :shell, path: "./scripts/initial.sh"
end
