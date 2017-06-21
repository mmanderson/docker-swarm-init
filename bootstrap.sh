#!/bin/bash

ps -aef | grep [a]pt > /dev/null
while [ $? -eq 0 ]; do
  echo "Waiting for current apt execution to complete"
  sleep 5
  ps -aef | grep [a]pt > /dev/null
done

apt-get update

# handle grub update
echo "set grub-pc/install_devices /dev/sda" | debconf-communicate
echo "Upgrading default packages"
apt-get upgrade -o Dpkg::Options::="--force-confold" -y

echo "Installing base packages"
apt-get install -y apt-transport-https libffi-dev libssl-dev python-pip python-dev
