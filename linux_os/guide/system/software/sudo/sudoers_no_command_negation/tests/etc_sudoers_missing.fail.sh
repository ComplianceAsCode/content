#!/bin/bash
# platform = SUSE Linux Enterprise 16
# packages = sudo
# remediation = none

if [ -e "/etc/sudoers" ] ; then
    rm "/etc/sudoers"
fi
echo 'nobody ALL=/bin/ls, (bob !alice) /bin/dog, /bin/cat !arg' > /etc/sudoers.d/foo
