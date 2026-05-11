#!/bin/bash
# platform = SUSE Linux Enterprise 16
# packages = sudo
# remediation = none

# create /etc/sudoers, otherwise OVAL will fail due to missing file
if [ ! -e "/etc/sudoers" ] ; then
    touch "/etc/sudoers"
fi
echo 'user ALL=(ALL) ALL' > /usr/etc/sudoers.d/user
