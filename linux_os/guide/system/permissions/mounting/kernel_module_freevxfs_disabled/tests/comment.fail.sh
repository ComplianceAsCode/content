#!/bin/bash

if [ -f /etc/modprobe.d/freevxfs.conf ]; then
    sed -i '/install freevxfs/d' /etc/modprobe.d/freevxfs.conf
fi
echo "# install freevxfs /bin/true" > /etc/modprobe.d/freevxfs.conf
