#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora
# remediation = none

cp /proc/cpuinfo /tmp/cpuinfo
sed -ir 's/^flags.*:.*nx.*/flags : /g' /tmp/cpuinfo
mount --bind /tmp/cpuinfo /proc/cpuinfo

cp /proc/cmdline /tmp/cmdline
sed -ir 's/\s+noexec[0-9]*=off[\s]*/noexec=on/g' /tmp/cmdline
mount --bind /tmp/cmdline /proc/cmdline
