#!/bin/bash
# platform = SUSE Linux Enterprise 16
# packages = sudo

if [ -e "/etc/sudoers" ] ; then
    rm "/etc/sudoers"
fi
echo "Defaults timestamp_timeout=3" >> /etc/sudoers.d/00-complianceascode-test.conf
