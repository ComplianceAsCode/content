#!/bin/bash
# platform = SUSE Linux Enterprise 16
# variables = sshd_max_auth_tries_value=4
source include.sh

touch "{{{ sshd_main_config_file }}}"
echo "MaxAuthTries 20" >> "{{{ sshd_config_dir }}}/01-complianceascode.conf"
