# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  
  # --- Common Configuration ---
  config.vm.box = "eurolinux-vagrant/centos-stream-9"
  
  # Hostmanager Plugin Configuration
  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.manage_guest = true
    config.hostmanager.os = "linux"
  else
    puts "Suggestion: Install 'vagrant-hostmanager' plugin for automatic /etc/hosts management."
    puts "Command: vagrant plugin install vagrant-hostmanager"
  end

  # --- VM Definitions ---
  # Define all VMs in a hash for cleaner management
  vms = {
    "db01"  => { ip: "192.168.56.15", mem: "2048", script: "db01.sh" },
    "mc01"  => { ip: "192.168.56.14", mem: "1024", script: "mc01.sh" },
    "rmq01" => { ip: "192.168.56.13", mem: "1024", script: "rmq01.sh" },
    "app01" => { ip: "192.168.56.12", mem: "4096", script: "app01.sh" },
    "web01" => { ip: "192.168.56.11", mem: "1024", script: "web01.sh" }
  }

  vms.each do |name, conf|
    config.vm.define name do |box|
      box.vm.hostname = name
      box.vm.network "private_network", ip: conf[:ip]
      
      # Provider Configuration (VirtualBox)
      box.vm.provider "virtualbox" do |vb|
        vb.memory = conf[:mem]
        vb.name = name
        # Optional: Set CPUs if needed
        # vb.cpus = 2 
      end

      # Provisioning
      box.vm.provision "shell", path: conf[:script]
    end
  end

end
