#!/bin/bash
# remediation = none

source common.sh
echo "AllowGroups " >> /etc/ssh/sshd_config
echo "DenyGroups " >> /etc/ssh/sshd_config
