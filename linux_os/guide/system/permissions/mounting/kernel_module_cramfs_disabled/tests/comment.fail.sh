#!/bin/bash

if [ -f /etc/modprobe.d/cramfs.conf ]; then
    sed -i '/install cramfs/d' /etc/modprobe.d/cramfs.conf
fi
echo "# install cramfs /bin/true" > /etc/modprobe.d/cramfs.conf
