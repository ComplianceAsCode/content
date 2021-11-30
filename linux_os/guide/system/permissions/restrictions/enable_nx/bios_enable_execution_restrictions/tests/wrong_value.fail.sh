#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora
# remediation = none

cp /proc/cpuinfo /tmp/cpuinfo
sed -i 's/nx//g' /tmp/cpuinfo
mount --bind /tmp/cpuinfo /proc/cpuinfo

cp /proc/cmdline /tmp/cmdline
sed -i 's/$/ noexec=off /' /tmp/cmdline
mount --bind /tmp/cmdline /proc/cmdline
