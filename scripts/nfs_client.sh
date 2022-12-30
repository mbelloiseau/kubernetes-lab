#!/bin/bash

apt install -y nfs-common

mkdir /mnt/data

grep "192.168.60.5:/data" /etc/fstab

if [ $? -ne 0 ] ; then
    echo "192.168.60.5:/data /mnt/data nfs defaults 0 0" >> /etc/fstab
    mount -a
fi