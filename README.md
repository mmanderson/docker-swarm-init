# Overview #

This is a set of Vagrant, ansible and associated scripts to set up a Docker Swarm.  The Vagrant scripts will create 4 VirtualBox VMs for the swarm and a VirtualBox VM for an ElasticStack server.  These servers will then be provisioned using ansible based on the local.yml inventory file in the ansible/hosts directory to set up a local swarm talking to a local ElasticStack server.  The ansible scripts can provision other machines by creating the necessary servers (virtual or otherwise) and creating an appropriate inventory file for them.

## Requirements

There are links below for more information on the software required.

 - VirtualBox 5.0+
 - vagrant 1.9.4+
 - ansible 2.2.1+


### Tested Host Operating Systems

 - Ubuntu 16.04
 - OS X

### Unsupported Operating Systems

use these at your own risk

 - Windows

### CPU

You need at least 4 cores, 8 cores is recommended.

### Memory

You need at least 8GB of addressable memory (RAM + swap) to install and run this environment.  I would strongly recommend at least 16GB of free memory, to avoid considerable slowing on your host system.


### Storage

You need at least 10-15 gigs of free local storage.


------------

## Installation/Update

Clone the repository using git with the following command:

    $ git clone git@github.com:mmanderson/docker-swarm-init.git

Not required but recommended.  Download and cache the base VM for the virtual machines.

    $ vagrant box add gbarbieru/xenial

Before running the ansible scripts (or running the `local_swarm.sh` script described below) you will need to install pip and ansible.  If you haven't already installed them you can install them by running:

    $ sudo easy_install pip
    $ sudo pip install --upgrade ansible

If you haven't installed the following ansible role you will need to install them by running the following command:

    $ sudo ansible-galaxy install geerlingguy.java

------------

## What will be installed

To support the swarm infrastructure we are installing a few different services.

* Elastic Stack - this set of services is used to capture all of the logs from the swarm so that we can monitor behavior and find and debug issues.

* Docker swarm - a cluster of Docker engines that provide a standard way of deploying, monitoring and updating our services so that we can run the exact same image in development, referrences and production

### Standing up a local swarm and service

To stand up a local swarm, there is a shell script (`local_swarm.sh`) that can be run to create the virtual machines, do some initial provisioning including copying your public ssh key to the root user's .ssh/authorized_keys file so that the script can complete the ansible provisioning in the virtual machines.  Once the virtual machines have been created, the script then runs the ansible playbooks to complete provisioning the elastic stack and the docker swarm.  Each of these steps can be run independently to bring up the swarm or update services running in it as described below.  If you run the `local_swarm.sh` script you can also skip to the end to [Verifying the elastic stack](#verifying-the-elastic-stack) and [Verify the docker swarm](#verify-the-docker-swarm)

# Individual installation instructions

### Vagrant

The Vagrant script will set up 5 Ubuntu 16.04 virtual machines on your local system.  To bring these VMs up with the initial provisioning, run:

    $ vagrant up --provision

Once this completes (and it will take a while the first time) you will have the base set of machines for running and testing a swarm.  In order to make sure that the machines are running with the latest installed packages (if vagrant up creates them for the first time) run

    $ vagrant halt

followed by

    $ vagrant up

You can also access the individual machines by running

    $ vagrant ssh [local-m0|local-m1|local-m2|local-w0|local-es]

or
    $ ssh vagrant@10.10.99.[102,210,211,212,220]

The password for the default `vagrant` user is `vagrant`

To shutdown the VMs use

    $ vagrant halt

To completely remove the VMs from your system use

    $ vagrant destroy -f

If you haven't set these machines up before, or have changed the directory that you are running from, you might need to ensure that the ssh keys for the machines have been added to your known_hosts file.  You can do that by sshing to each of the machines and accepting the credentials for that machine.  The machines are avaliable at the following addresses:

    10.10.99.102 - Elastic stack
    10.10.99.210 - Docker swarm master 0
    10.10.99.211 - Docker swarm master 1
    10.10.99.212 - Docker swarm master 2
    10.10.99.220 - Docker swarm worker 0

### Ansible playbook to set up Elastic Stack components

If you haven't installed it already, the elasticstack playbook has a dependency:

    $ sudo ansible-galaxy install geerlingguy.java

To run the playbook against existing machines you will need a machine (virtual or physical) running Ubuntu 16.04 with python and pip already installed.  You will need a user on the machines that you can access via ssh that has the ability to run sudo (if not logging in as root) to install packages and configure the system.  You can copy and update the `local.yml` file under ansible/hosts to match the machine you would like to install to.  The `local.yml` file under ansible/hosts should already match the configuration created by the Vagrantfile.

Depending on the user that you login to the machines as, you can run the playbook slightly different.  If you ssh onto the machines as root, you can use the following command

    $ ansible-playbook -i ansible/hosts/[local.yml|dev.yml|prod.yml] --user root ansible/es_all.yml

If you will be using ssh as yourself, you don't have to specify the `--user`parameter.  If a password is required to login via ssh, you can specify the `--ask-pass` parameter to have ansible prompt you for the password.  If sudo is set up to require a password, you can use the `--ask-become-pass` parameter to have ansible prompt for your password on the machines you are running the playbook against when it runs the sudo command on those machines.

Once the playbook completes, you should be able check the status by following the steps in the [Verify the elastic stack](#verifying-the-elastic-stack) section.

### Verifying the elastic stack

Once you have used ansible to provision the services, you should be able to access the nginx "front-end" server to verify the services.  For the local environment, you can access it at 10.10.99.102.  Switch that address in the links below to the appropriate one for the environment you provisioned and deployed into.

[http://10.10.99.102](http://10.10.99.102) - will access the main Kibana page.

**NOTE:** You won't be able to set up an index until you have generated some log data into the ElasticStack from the swarm.

### Ansible playbook to set up the docker swarm

To run the playbook against existing machines you will need four machines (virtual or physical) running Ubuntu 16.04 with python and pip already installed.  You will need a user on the machines that you can access via ssh that has the ability to run sudo (if not loggin in as root) to install packages and configure the system.  You can create an additional inventory file under ansible/hosts to match the machines you would like to install to.  The local.yml file under ansible/hosts should already match the configuration created by the Vagrantfile.

Depending on the user that you login to the machines as, you can run the playbook slightly different.  If you ssh onto the machines as root, you can use the following command

    $ ansible-playbook -i ansible/hosts/[dev.yml|prod.yml] --user root ansible/swarm_all.yml

If you will be using ssh as yourself, you don't have to specify the `--user`parameter.  If a password is required to login via ssh, you can specify the `--ask-pass` parameter to have ansible prompt you for the password.  If sudo is set up to require a password, you can use the `--ask-become-pass` parameter to have ansible prompt for your password on the machines you are running the playbook against when it runs the sudo command on those machines.

### Verify the docker swarm

Once the playbook completes, you should be able check the swarm status by sshing into one of the swarm managers (see the list of machines in the docker_swarm_manager section of the appropriate yml file under ansible/hosts) and running

    $ docker node ls

This will list the nodes in the swarm and their current status.

You can also see the status of all of the services by sshing into one of the swarm managers (see the list of machines in the docker_swarm_manager section of the appropriate yml file under ansible/hosts) and running

    $ docker service ls

This will list the services in the swarm and how many instances of each are running.  You can then run

    $ docker service ps <name>

to see the status of the individual services and where they are running in the swarm

The docker swarm nodes are also set up to allow remote administration.  If you have docker installed on the host, you can also try the following commands against local-swarm-m0:

    $ docker -H tcp:10.10.99.210:2375 docker node ls
    $ docker -H tcp:10.10.99.210:2375 docker service ls
    $ docker -H tcp:10.10.99.210:2375 docker service ps <name>

## Links

 - [virtualbox](https://www.virtualbox.org/wiki/Downloads)
 - [vagrant](https://www.vagrantup.com/downloads.html)
 - [ansible](http://docs.ansible.com/ansible/intro_installation.html) <= this is python package just use `pip install ansible`
 - [Docker swarm mode](https://docs.docker.com/engine/swarm/)
 - [ElasticStack](https://www.elastic.co/start)
 