require "yaml"
require "fileutils"

CONFIG = File.expand_path("config.rb")
if File.exist?(CONFIG)
  require CONFIG
end

## if enable openstack provider, you must install this plugin
# require "vagrant-openstack-provider"

Vagrant.configure("2") do |config|
    config.vm.box = $box_image
    machine_total = $master_count + $node_count

    ## Setting bridge network and vm infos
    if $bridge_enable && $bridge_eth.to_s != ''
        config.vm.network "public_network", bridge: $bridge_eth
    end
    config.vm.provider "virtualbox" do |vm|
        vm.memory = $system_memory
        vm.cpus = $system_vcpus
    end

    ## Configuration of machines
    (1..machine_total).each do |machine_id|
        name = (machine_id <= $master_count) ? $master_prefix : $node_prefix
        id   = (machine_id <= $master_count) ? machine_id : (machine_id - $master_count)

        config.vm.define "#{name}#{id}" do |subconfig|
            subconfig.vm.hostname = "#{name}#{id}"
            subconfig.vm.network "private_network", ip: "#{$private_subnet}.#{$private_count}", auto_config: true
            $private_count += 1

            ## Create extra disk at nodes
            if machine_id > $master_count
                (1..$disk_count).each do |disk_id|
                    subconfig.vm.provider "virtualbox" do |vm|
                        vm.customize ["createhd",  "--filename", "#{$storage_path}n#{id}d#{disk_id}", "--size", $storage_size]
                        vm.customize [
                            "storageattach", :id,
                            "--storagectl", "SATA Controller",
                            "--port", "#{disk_id}",
                            "--type", "hdd",
                            "--medium", "#{$storage_path}n#{id}d#{disk_id}.vdi"
                        ]
                    end
                end
            end

            ## Install of dependency packages using Ansible playbooks
            if machine_total == machine_id && $enable_ansible
                subconfig.vm.provision :ansible do |ansible|
                # Disable default limit to connect to all the machines
                    ansible.limit = "all"
                    ansible.sudo = true
                    ansible.host_key_checking = false
                    ansible.playbook = $ansible_playboos
                    ansible.groups = $ansible_groups
                end
            end
        end
    end
    ## Install of dependency packages using script
    # config.vm.provision :shell, path: "install-dep.sh"
end
