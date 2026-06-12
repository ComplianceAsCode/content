#!/bin/bash
# variables = var_sshd_set_maxstartups=10:30:60

if grep -q "^MaxStartups" "{{{ sshd_main_config_file }}}"; then
	sed -i "s/^MaxStartups.*/MaxStartups 10:30:61/" "{{{ sshd_main_config_file }}}"
else
	echo "MaxStartups 10:30:61" >> "{{{ sshd_main_config_file }}}"
fi
