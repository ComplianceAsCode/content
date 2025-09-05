# profiles = xccdf_org.ssgproject.content_profile_cis
# platform = Red Hat Enterprise Linux 8

#!/bin/bash
SSHD_CONFIG="/etc/ssh/sshd_config"

if grep -q "^MaxSessions" $SSHD_CONFIG; then
        sed -i "s/^MaxSessions.*/MaxSessions 4/" $SSHD_CONFIG
    else
        echo "MaxSessions 4" >> $SSHD_CONFIG
fi
