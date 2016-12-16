require "yaml"
require "fileutils"

CONFIG = File.expand_path("config.rb")
if File.exist?(CONFIG)
  require CONFIG
end

Vagrant.configure("2") do |config|
    ## Configuration of Masters
    config.vm.box = $box_image
    (1..$master_count).each do |i|
        config.vm.define "master#{i}" do |subconfig|
            subconfig.vm.hostname = "master#{i}"
            subconfig.vm.network "private_network", ip: "172.16.35.1#{i}", auto_config: true
        end
    end

    ## Configuration of Nodes
    (1..$node_count).each do |i|
        config.vm.define "node#{i}" do |subconfig|
            subconfig.vm.hostname = "node#{i}"
            subconfig.vm.network "private_network", ip: "172.16.35.2#{i}", auto_config: true

            ## Create node disks
            (1..$disk_count).each do |j|
                subconfig.vm.provider "virtualbox" do |vm|
                    vm.customize ["createhd",  "--filename", "#{$storage_path}n#{i}d#{j}", "--size", $storage_size]
                    vm.customize [
                        "storageattach", :id,
                        "--storagectl", "SATA Controller",
                        "--port", "#{j}",
                        "--type", "hdd",
                        "--medium", "#{$storage_path}n#{i}d#{j}.vdi"
                    ]
                end
            end
        end
    end

    ## Configure vm infos
    config.vm.provision :shell, path: "install-dep.sh"
    if $bridge_enable && $bridge_eth.to_s != ''
            config.vm.network "public_network", bridge: $bridge_eth
    end
    config.vm.provider "virtualbox" do |vm|
        vm.memory = $system_memory
        vm.cpus = $system_vcpus
    end
end
