#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora
# remediation = none

cp /proc/cpuinfo /tmp/cpuinfo
sed -i 's/^flags.*:.*/& nx/g' /tmp/cpuinfo
mount --bind /tmp/cpuinfo /proc/cpuinfo

cp /proc/cmdline /tmp/cmdline
sed -r 's/\s+noexec[0-9]*=off[\s]*//g' /tmp/cmdline
mount --bind /tmp/cmdline /proc/cmdline
