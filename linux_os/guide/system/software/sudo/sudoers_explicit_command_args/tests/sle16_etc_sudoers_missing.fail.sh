#!/bin/bash
# platform = SUSE Linux Enterprise 16
# packages = sudo
# remediation = none

if [ -e "/etc/sudoers" ] ; then
    rm "/etc/sudoers"
fi
# correct entries in default drop-ins, OVAL should fail if /etc/sudoers is missing
echo 'nobody ALL=/bin/ls arg arg, (bob,!alice) /bin/dog arg, /bin/cat arg' > /etc/sudoers.d/foo
echo 'nobody ALL=/bin/ls arg arg, (bob,!alice) /bin/dog arg, /bin/cat arg' > /usr/etc/sudoers.d/foo
