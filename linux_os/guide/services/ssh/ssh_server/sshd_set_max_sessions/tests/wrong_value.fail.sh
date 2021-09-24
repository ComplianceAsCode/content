# platform = multi_platform_rhel, multi_platform_fedora

#!/bin/bash
SSHD_CONFIG="/etc/ssh/sshd_config"

if grep -q "^MaxSessions" $SSHD_CONFIG; then
        sed -i "s/^MaxSessions.*/MaxSessions 100/" $SSHD_CONFIG
    else
        echo "MaxSessions 100" >> $SSHD_CONFIG
fi
