#!/bin/bash
# platform = SUSE Linux Enterprise 16
# packages = sudo

if [ -e "/etc/sudoers" ] ; then
    rm "/etc/sudoers"
fi
echo "Defaults use_pty" >> /etc/sudoers.d/enable_use_pty
