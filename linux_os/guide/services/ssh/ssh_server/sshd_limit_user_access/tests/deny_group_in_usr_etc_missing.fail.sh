#!/bin/bash
# remediation = none
# platform = SUSE Linux Enterprise 16
source common.sh

touch /etc/ssh/sshd_config
echo "DenyGroups testgroup" >> /usr/etc/ssh/sshd_config
