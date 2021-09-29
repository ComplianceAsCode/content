#!/bin/bash
#
# platform = multi_platform_rhel,multi_platform_fedora
#
# remediation = none


if [ -e /etc/cpuinfo ] ; then
> /tmp/cpuinfo
cp /proc/cpuinfo /tmp/cpuinfo
if grep -Fxq 's/^flags.*:.*/& nx/g' /tmp/cpuinfo ; then
sed -i 's/^flags.*:.*/& nx/g' /tmp/cpuinfo
else
echo '' >> /tmp/cpuinfo
fi
mount --bind /etc/cpuinfo /proc/cpuinfo
fi

if [ -e /etc/cmdline ] ; then
> /tmp/cmdline
cp /proc/cmdline /tmp/cmdline
if grep -Fxq sed -r 's/\s+noexec[0-9]*=off[\s]*//g' /tmp/cmdline ; then
sed -r 's/\s+noexec[0-9]*=off[\s]*//g' /tmp/cmdline
else
echo '' >> /tmp/cmdline
fi
mount --bind /etc/cmdline /proc/cmdline
fi
