#!/bin/bash
# platform = SUSE Linux Enterprise 16
# packages = sudo
# remediation = none

if [ ! -e "/etc/sudoers" ] ; then
    touch "/etc/sudoers"
fi
echo 'user,!example ALL,SERVERS = /bin/sh ' > /usr/etc/sudoers.d/foo
