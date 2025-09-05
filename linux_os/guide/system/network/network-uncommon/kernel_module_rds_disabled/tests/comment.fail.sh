#!/bin/bash

if [ -f /etc/modprobe.d/rds.conf ]; then
    sed -i '/install rds/d' /etc/modprobe.d/rds.conf
fi
echo "# install rds /bin/true" > /etc/modprobe.d/rds.conf
