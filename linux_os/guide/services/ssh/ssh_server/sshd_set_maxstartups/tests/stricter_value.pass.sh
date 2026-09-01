#!/bin/bash
# variables = var_sshd_set_maxstartups=10:30:60

if grep -q "^MaxStartups" "{{{ sshd_main_config_file }}}"; then
	sed -i "s/^MaxStartups.*/MaxStartups 5:60:30/" "{{{ sshd_main_config_file }}}"
else
	echo "MaxStartups 5:60:30" >> "{{{ sshd_main_config_file }}}"
fi
