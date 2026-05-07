#!/bin/bash
# platform = SUSE Linux Enterprise 16
# packages = sudo
# remediation = none

# remove /etc/sudoers for SUSE Linux Enterprise 16
# test should fail, by default no drop-in sudoers configuration is present
if [ -e "/etc/sudoers" ] ; then
    rm "/etc/sudoers"
fi
