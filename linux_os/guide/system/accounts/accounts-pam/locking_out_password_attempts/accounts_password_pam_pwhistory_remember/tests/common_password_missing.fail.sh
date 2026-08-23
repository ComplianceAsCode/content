#!/bin/bash
# platform = SUSE Linux Enterprise 16
# packages = pam

if [ -e "/etc/pam.d/common-password" ] ; then
    rm "/etc/pam.d/common-password"
fi
