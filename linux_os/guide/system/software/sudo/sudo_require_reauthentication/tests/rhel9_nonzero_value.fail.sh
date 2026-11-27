#!/bin/bash
# platform = Red Hat Enterprise Linux 9
# packages = sudo
# variables = var_sudo_timestamp_timeout=0

if grep -q 'timestamp_timeout' /etc/sudoers; then
    sed -i 's/.*timestamp_timeout.*/Defaults timestamp_timeout=3/' /etc/sudoers
else
    echo "Defaults timestamp_timeout=3" >> /etc/sudoers
fi
