#!/bin/bash
#
# platform = multi_platform_rhel,multi_platform_fedora
#
# remediation = none

> /tmp/cpuinfo
> /tmp/cmdline

if [ -e /tmp/cpuinfo ] && [ -e /proc/cpuinfo ]; then
cp /proc/cpuinfo /tmp/cpuinfo
if grep -Fxq '^flags.*:.*/& nx' /tmp/cpuinfo ; then
sed -i 's/^flags.*:.*/& nx/g' /tmp/cpuinfo
else
echo 'flags = nx' >> /tmp/cpuinfo
fi
mount --bind /tmp/cpuinfo /proc/cpuinfo
fi

if [ -e /tmp/cmdline ] && [ -e /proc/cmdline ]; then
cp /proc/cmdline /tmp/cmdline
if grep -Fxq sed -r '\s+noexec[0-9]*=off[\s]*' /tmp/cmdline ; then
sed -r 's/\s+noexec[0-9]*=off[\s]*//g' /tmp/cmdline
else
echo 'noexec100=off' >> /tmp/cmdline
fi
mount --bind /tmp/cmdline /proc/cmdline
fi