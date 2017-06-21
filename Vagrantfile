# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "gbarbieru/xenial"
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
  end
  config.vm.synced_folder "~/.ssh", "/vagrant/root/.ssh"
  config.vm.provision :shell, path: "bootstrap.sh"

   # Elastic stack for logging
  config.vm.define "local-elasticstack" do |node|
    node.vm.hostname = "local-elasticstack"
    node.vm.network "private_network", ip: "10.100.199.102"
    node.vm.provider "virtualbox" do |v|
      v.name = "local-elasticstack"
      v.cpus = 2
    end
  end

  # Swarm Master nodes
  (0..2).each do |i|
    config.vm.define "local-swarm-m#{i}" do |node|
      node.vm.hostname = "local-swarm-m#{i}"
      node.vm.network "private_network", ip: "10.100.199.21#{i}"
      node.vm.provider "virtualbox" do |v|
        v.name = "local-swarm-m#{i}"
      end
    end
  end

  # Swarm worker node
  config.vm.define "local-swarm-n0" do |node|
    node.vm.hostname = "local-swarm-n0"
    node.vm.network "private_network", ip: "10.100.199.220"
    node.vm.provider "virtualbox" do |v|
      v.name = "local-swarm-n0"
    end
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end
end