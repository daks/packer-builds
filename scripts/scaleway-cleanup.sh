#!/bin/bash

# system upgrade
apt-get update && apt-get -y upgrade

# clean up
apt-get -y --purge remove linux-headers-$(uname -r) build-essential
apt-get -y --purge autoremove
apt-get -y purge $(dpkg --list |grep '^rc' |awk '{print $2}')
apt-get -y purge $(dpkg --list |egrep 'linux-image-[0-9]' |awk '{print $3,$2}' |sort -nr |tail -n +2 |grep -v $(uname -r) |awk '{ print $2}')
apt-get -y clean

# delete cloud-init user
deluser debian
rm -fr /home/debian

# remove history file
unset HISTFILE
rm -f ~/.bash_history 

# sync data to disk (fix packer)
sync
