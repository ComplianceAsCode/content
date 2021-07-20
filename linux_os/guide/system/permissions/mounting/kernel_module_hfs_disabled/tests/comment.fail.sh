#!/bin/bash

if [ -f /etc/modprobe.d/hfs.conf ]; then
    sed -i '/install hfs/d' /etc/modprobe.d/hfs.conf
fi
echo "# install hfs /bin/true" > /etc/modprobe.d/hfs.conf
