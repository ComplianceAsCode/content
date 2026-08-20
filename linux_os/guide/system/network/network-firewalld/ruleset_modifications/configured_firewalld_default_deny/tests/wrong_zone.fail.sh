#!/bin/bash
# packages = firewalld
# platform = multi_platform_all

mkdir -p /etc/firewalld
touch /etc/firewalld/firewalld.conf
if grep -q "^DefaultZone=" /etc/firewalld/firewalld.conf; then
    sed -i 's/^DefaultZone=.*/DefaultZone=public/' /etc/firewalld/firewalld.conf
else
    echo "DefaultZone=public" >> /etc/firewalld/firewalld.conf
fi
