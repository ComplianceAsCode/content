#!/bin/bash
# platform = SUSE Linux Enterprise 16
# variables = var_sshd_set_maxstartups=10:30:60
source include.sh

touch "{{{ sshd_main_config_file }}}"
echo "MaxStartups 10:30:61" >> "{{{ sshd_config_dir }}}/01-complianceascode.conf"
