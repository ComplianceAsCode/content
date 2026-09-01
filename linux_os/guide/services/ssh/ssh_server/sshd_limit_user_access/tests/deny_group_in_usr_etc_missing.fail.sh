#!/bin/bash
# remediation = none
# platform = SUSE Linux Enterprise 16
source common.sh

touch "{{{ sshd_main_config_file }}}"
echo "DenyGroups testgroup" >> /usr/etc/ssh/sshd_config
