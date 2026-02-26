#!/bin/bash
# remediation = none

source common.sh
echo "AllowUsers " >> /etc/ssh/sshd_config
echo "DenyUsers " >> /etc/ssh/sshd_config
