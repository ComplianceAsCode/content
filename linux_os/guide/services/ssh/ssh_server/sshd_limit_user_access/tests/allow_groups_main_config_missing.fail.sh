#!/bin/bash
# remediation = none
# platform = SUSE Linux Enterprise 16
source common.sh
echo "AllowGroups group" >> "{{{ sshd_config_dir }}}/01-complianceascode-reinforce-os-defaults.conf"
