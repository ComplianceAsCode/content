#!/bin/bash
# platform = SUSE Linux Enterprise 16
# variables = var_sshd_max_sessions=4
source include.sh

touch "{{{ sshd_main_config_file }}}"
echo "MaxSessions 20" >> "{{{ sshd_config_dir }}}/01-complianceascode.conf"
