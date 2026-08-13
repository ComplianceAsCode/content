#!/bin/bash
# packages = firewalld
# platform = multi_platform_all

if grep -q "^DefaultZone=" /etc/firewalld/firewalld.conf; then
    sed -i 's/^DefaultZone=.*/DefaultZone=drop/' /etc/firewalld/firewalld.conf
else
    echo "DefaultZone=drop" >> /etc/firewalld/firewalld.conf
fi
