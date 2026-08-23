#!/bin/bash
# platform = SUSE Linux Enterprise 16
# packages = sudo

if [ -e "/etc/sudoers" ] ; then
    rm "/etc/sudoers"
fi
echo "Defaults logfile=/var/log/sudo.log" >> /etc/sudoers.d/enable_logfile
