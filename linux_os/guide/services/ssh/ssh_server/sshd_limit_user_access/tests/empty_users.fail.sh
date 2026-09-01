#!/bin/bash
# remediation = none

source common.sh
echo "AllowUsers " >> "{{{ sshd_main_config_file }}}"
echo "DenyUsers " >> "{{{ sshd_main_config_file }}}"
