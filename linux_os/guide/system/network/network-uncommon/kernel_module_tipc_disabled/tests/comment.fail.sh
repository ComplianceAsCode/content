#!/bin/bash

if [ -f /etc/modprobe.d/tipc.conf ]; then
    sed -i '/install tipc/d' /etc/modprobe.d/tipc.conf
fi
echo "# install tipc /bin/true" > /etc/modprobe.d/tipc.conf
