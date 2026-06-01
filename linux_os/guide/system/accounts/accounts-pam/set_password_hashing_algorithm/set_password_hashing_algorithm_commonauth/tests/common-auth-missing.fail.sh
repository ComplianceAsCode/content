#!/bin/bash
# platform = SUSE Linux Enterprise 16

if [ -e "/etc/pam.d/common-auth" ] ; then
    rm "/etc/pam.d/common-auth"
fi
