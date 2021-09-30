#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora
# remediation = none

> /tmp/cpuinfo
> /tmp/cmdline

if [ cp /proc/cpuinfo /tmp/cpuinfo ]; then
if grep -q '^flags.*:.*/& nx' /tmp/cpuinfo ; then
sed -i 's/^flags.*:.*/& nx/g' /tmp/cpuinfo
else
echo 'flags = nx' >> /tmp/cpuinfo
fi
mount --bind /tmp/cpuinfo /proc/cpuinfo
fi

if [ cp /proc/cmdline /tmp/cmdline ]; then
if grep -q '\s+noexec[0-9]*=off[\s]*' /tmp/cmdline ; then
sed -r 's/\s+noexec[0-9]*=off[\s]*//g' /tmp/cmdline
else
echo 'noexec100=off' >> /tmp/cmdline
fi
mount --bind /tmp/cmdline /proc/cmdline
fi