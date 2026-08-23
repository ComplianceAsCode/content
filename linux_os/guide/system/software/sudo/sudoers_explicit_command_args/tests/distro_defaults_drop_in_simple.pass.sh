#!/bin/bash
# platform = SUSE Linux Enterprise 16
# packages = sudo
# remediation = none

if [ ! -e "/etc/sudoers" ] ; then
    touch "/etc/sudoers"
fi
echo 'nobody ALL=/bin/ls arg arg, (bob,!alice) /bin/dog arg, /bin/cat arg' > /etc/sudoers.d/foo
echo 'nobody ALL=/bin/ls arg arg, (bob,!alice) /bin/dog arg, /bin/cat arg' > /usr/etc/sudoers.d/foo
