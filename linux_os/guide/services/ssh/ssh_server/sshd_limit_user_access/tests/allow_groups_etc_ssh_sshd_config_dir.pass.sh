#!/bin/bash
# platform = SUSE Linux Enterprise 16
source common.sh
touch "{{{ sshd_main_config_file }}}"
echo "AllowGroups group" >> "{{{ sshd_config_dir }}}/01-complianceascode-reinforce-os-defaults.conf"
