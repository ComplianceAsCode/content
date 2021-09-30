#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora
# remediation = none

cp /proc/cpuinfo /tmp/cpuinfo
sed -i 's/^flags.*:.*nx.*/& flags : pass_flag_scenario/g' /tmp/cpuinfo
mount --bind /tmp/cpuinfo /proc/cpuinfo

cp /proc/cmdline /tmp/cmdline
if ! grep '\s+noexec[0-9]*=off[\s]*'
echo ' noexec10=off' > /tmp/cmdline 
fi
mount --bind /tmp/cmdline /proc/cmdline
