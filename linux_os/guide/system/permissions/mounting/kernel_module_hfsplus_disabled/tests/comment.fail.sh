#!/bin/bash

if [ -f /etc/modprobe.d/hfsplus.conf ]; then
    sed -i '/install hfsplus/d' /etc/modprobe.d/hfsplus.conf
fi
echo "# install hfsplus /bin/true" > /etc/modprobe.d/hfsplus.conf
