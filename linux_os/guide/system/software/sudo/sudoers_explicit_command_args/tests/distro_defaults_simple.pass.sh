#!/bin/bash
# platform = SUSE Linux Enterprise 16
# packages = sudo
# remediation = none

if [ -e "/etc/sudoers" ] ; then
    rm "/etc/sudoers"
fi
echo 'nobody ALL=/bin/ls "", (!bob,alice) /bin/dog arg, /bin/cat ""' > /usr/etc/sudoers
echo 'jen,!fred		ALL,!SERVERS = /bin/sh arg' >> /usr/etc/sudoers
echo 'nobody ALL=/bin/ls arg arg, (bob,!alice) /bin/dog arg, /bin/cat arg' > /etc/sudoers.d/foo
echo 'nobody ALL=/bin/ls arg arg, (bob,!alice) /bin/dog arg, /bin/cat arg' > /usr/etc/sudoers.d/foo
