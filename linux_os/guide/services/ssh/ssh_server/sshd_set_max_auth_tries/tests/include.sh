#!/bin/bash

declare -a SSHD_PATHS=("/etc/ssh/sshd_config")
{{% if product == 'sle16' %}}
SSHD_PATHS+=("/usr/etc/ssh/sshd_config" /usr/etc/ssh/sshd_config.d/* /etc/ssh/sshd_config.d/*)
{{% endif %}}
# clean up configurations
sed -i '/^MaxAuthTries.*/d' "${SSHD_PATHS[@]}"

# restore to defaults for sle16
{{% if product == 'sle16' %}}
if [ -e "/etc/ssh/sshd_config" ] ; then
    rm /etc/ssh/sshd_config
fi
{{% endif %}}
