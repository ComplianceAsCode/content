#!/bin/bash
{{% if 'suse' in families %}}
# platform = Not Applicable
{{% else %}}
# platform = multi_platform_all
{{% endif %}}

# Includes the config directory, but not in the form the check expects
rm -f "{{{ sshd_config_dir }}}/sshd_config_original.conf"
mkdir -p "{{{ sshd_config_dir }}}"
echo "include {{{ sshd_config_dir | replace(sshd_config_base_dir ~ "/", "", 1) }}}/*.conf" > "{{{ sshd_main_config_file }}}"
