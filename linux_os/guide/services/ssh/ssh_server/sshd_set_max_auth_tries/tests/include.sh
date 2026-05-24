#!/bin/bash

declare -a SSHD_PATHS=("{{{ sshd_main_config_file }}}")
{{% if product in [ 'sle16', 'slmicro6' ] %}}
SSHD_PATHS+=("{{{ sshd_config_dir }}}/*")
{{% endif %}}
# clean up configurations
sed -i '/^MaxAuthTries.*/d' "${SSHD_PATHS[@]}"

# restore to defaults for sle16 and slmicro6
{{% if product in [ 'sle16', 'slmicro6' ] %}}
if [ -e "{{{ sshd_main_config_file }}}" ] ; then
    rm "{{{ sshd_main_config_file }}}"
fi
{{% endif %}}
