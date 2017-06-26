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
  config.vm.define "local-es" do |node|
    node.vm.hostname = "local-es"
    node.vm.network "private_network", ip: "10.10.99.102"
    node.vm.provider "virtualbox" do |v|
      v.name = "local-es"
      v.cpus = 2
    end
  end

  # Swarm Master nodes
  (0..2).each do |i|
    config.vm.define "local-m#{i}" do |node|
      node.vm.hostname = "local-m#{i}"
      node.vm.network "private_network", ip: "10.10.99.21#{i}"
      node.vm.provider "virtualbox" do |v|
        v.name = "local-m#{i}"
      end
    end
  end

  # Swarm worker node
  config.vm.define "local-w0" do |node|
    node.vm.hostname = "local-w0"
    node.vm.network "private_network", ip: "10.10.99.220"
    node.vm.provider "virtualbox" do |v|
      v.name = "local-w0"
    end
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end
end