#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora
# remediation = none

yes | cp /proc/cpuinfo /tmp/cpuinfo
if ! grep '^flags.*:.*nx.*' /tmp/cpuinfo ; then
    echo 'flags : nx' >> /tmp/cpuinfo
fi
mount --bind /tmp/cpuinfo /proc/cpuinfo

yes | cp /proc/cmdline /tmp/cmdline
sed -i 's/^flags.*:.*nx.*/& flags : pass_flag_scenario/g' /tmp/cpuinfo
mount --bind /tmp/cmdline /proc/cmdline



