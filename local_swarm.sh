#!/bin/bash

# Bring up the virtual machines
vagrant up
if [ $? -ne 0 ]; then
    error=$?
    echo "There was a problem creating/starting the virtual machines"
    exit $error
fi

echo "Sleep for a little bit to make sure VMs are up before completing provisioning"
sleep 30s

# Make sure we have the VMs in the known_hosts file
sshhash=$(grep HashKnownHosts /etc/ssh/ssh_config | grep yes)
dohash=''
if [ "x$sshhash" != "x" ]; then
    dohash='-H'
fi

function check_and_add_host {
    host=$1

    echo "Checking for $host"
    ssh-keygen -F $host
    while [ $? -ne 0 ]; do
        echo "Trying to add $host"
        ssh-keyscan $dohash $host >> ~/.ssh/known_hosts
        sleep 1s
        ssh-keygen -F $host
    done
}

check_and_add_host 10.10.99.102
check_and_add_host 10.10.99.210
check_and_add_host 10.10.99.211
check_and_add_host 10.10.99.212
check_and_add_host 10.10.99.220

# Provision our elasticstack
echo "When prompted for an SSH password, enter 'vagrant'"
ansible-playbook -i ansible/hosts/local.yml --user vagrant -k ansible/es_all.yml
if [ $? -ne 0 ]; then
    error=$?
    echo "There was a problem provisioning the elasticstack environment"
    exit $error
fi

# Provision the swarm
echo "When prompted for an SSH password, enter 'vagrant'"
ansible-playbook -i ansible/hosts/local.yml --user vagrant -k ansible/swarm_all.yml
if [ $? -ne 0 ]; then
    error=$?
    echo "There was a problem provisioning the docker swarm environment"
    exit $error
fi
