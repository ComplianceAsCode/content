#!/bin/bash

if [ -f /etc/modprobe.d/squashfs.conf ]; then
    sed -i '/install squashfs/d' /etc/modprobe.d/squashfs.conf
fi
echo "# install squashfs /bin/true" > /etc/modprobe.d/squashfs.conf
