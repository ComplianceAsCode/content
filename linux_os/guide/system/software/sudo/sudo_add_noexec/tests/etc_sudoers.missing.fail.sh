#!/bin/bash
# platform = SUSE Linux Enterprise 16
# packages = sudo

if [ -e "/etc/sudoers" ] ; then
    rm "/etc/sudoers"
fi
echo "Defaults noexec" >> /etc/sudoers.d/enable_noexec
