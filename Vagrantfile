# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.env.enable
  config.vm.box = "bento/ubuntu-22.04"

  config.vm.synced_folder "scripts/", "/opt/scripts"
  config.vm.synced_folder "shared/", "/opt/shared"
  config.vm.synced_folder "manifests/", "/opt/manifests"

  config.vm.provider "virtualbox" do |v|
    v.memory = 2024
    v.cpus = 2
  end

  $update_hosts = <<-SCRIPT
    echo "192.168.60.10 k8s-master" >> /etc/hosts
    echo "192.168.60.11 k8s-worker-1" >> /etc/hosts
    echo "192.168.60.12 k8s-worker-2" >> /etc/hosts
  SCRIPT

  config.vm.define "k8s-master" do |master|
    master.vm.hostname = "k8s-master"
    master.vm.network "private_network", ip: "192.168.60.10",
      auto_config: true
    master.vm.provision "shell", inline: $update_hosts
    master.vm.provision "shell", path: "scripts/common.sh"
    master.vm.provision "shell", path: "scripts/master.sh"
    master.vm.provision "shell", path: "scripts/tools.sh"
    master.vm.network "forwarded_port", guest: 6443, host: 6443
  end

  (1..2).each do |i|
    config.vm.define "k8s-worker-#{i}" do |worker|
      worker.vm.hostname = "k8s-worker-#{i}"
      worker.vm.network "private_network", ip: "192.168.60.#{i+10}",
        auto_config: true
      worker.vm.provision "shell", inline: $update_hosts
      worker.vm.provision "shell", path: "scripts/common.sh"
      worker.vm.provision "shell", path: "scripts/nfs_client.sh"
      worker.vm.provision "shell", path: "shared/join.sh" 
    end
  end
end
