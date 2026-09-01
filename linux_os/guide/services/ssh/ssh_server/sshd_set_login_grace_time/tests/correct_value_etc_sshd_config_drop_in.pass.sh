#!/bin/bash
# platform = SUSE Linux Enterprise 16
source include.sh
touch "{{{ sshd_main_config_file }}}"
echo "LoginGraceTime 60" >> "{{{ sshd_config_dir }}}/01-complianceascode-reinforce-os-defaults.conf"
