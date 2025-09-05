#!/bin/bash
# platform = Red Hat Enterprise Linux 9

# Clean sysctl config directories
rm -rf /usr/lib/sysctl.d/* /run/sysctl.d/* /etc/sysctl.d/*

sed -i "/kernel.unprivileged_bpf_disabled/d" /etc/sysctl.conf
echo "kernel.unprivileged_bpf_disabled = 0" >> /etc/sysctl.conf

# set correct runtime value to check if the filesystem configuration is evaluated properly
sysctl -w kernel.unprivileged_bpf_disabled="0"
