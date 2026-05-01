#!/bin/bash
# platform = SUSE Linux Enterprise 16
# packages = sudo
# remediation = none

if [ -e "/etc/sudoers" ] ; then
    rm "/etc/sudoers"
fi
echo 'user ALL=(ALL) ALL' > /usr/etc/sudoers.d/foo
