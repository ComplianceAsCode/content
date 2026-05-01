#!/bin/bash
# platform = SUSE Linux Enterprise 16
# packages = sudo
# remediation = none

if [ -e "/etc/sudoers" ] ; then
    rm "/etc/sudoers"
fi
sed -i "/^root[[:space:]]*ALL=(ALL:ALL)[[:space:]]*ALL/d" /usr/etc/sudoers
echo 'user,!example ALL,SERVERS = /bin/sh ' > /usr/etc/sudoers
