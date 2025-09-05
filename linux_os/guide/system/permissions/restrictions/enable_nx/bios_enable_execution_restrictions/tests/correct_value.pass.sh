#!/bin/bash
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel
# remediation = none

cp /proc/cpuinfo /tmp/cpuinfo
sed -i 's/^flags.*:.*/& nx/g' /tmp/cpuinfo
mount --bind /tmp/cpuinfo /proc/cpuinfo

cp /proc/cmdline /tmp/cmdline
sed -i 's/noexec[0-9]*=off//g' /tmp/cmdline
mount --bind /tmp/cmdline /proc/cmdline

if [ -f "/var/log/messages" ]; then
    sed -i 's/protection: disabled//g' /var/log/messages
fi

