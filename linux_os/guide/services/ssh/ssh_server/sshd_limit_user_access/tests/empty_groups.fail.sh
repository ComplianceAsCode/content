#!/bin/bash
# remediation = none

source common.sh
echo "AllowGroups " >> "{{{ sshd_main_config_file }}}"
echo "DenyGroups " >> "{{{ sshd_main_config_file }}}"
