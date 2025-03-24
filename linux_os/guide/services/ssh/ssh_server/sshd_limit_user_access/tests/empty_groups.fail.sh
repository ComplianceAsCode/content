#!/bin/bash
# remediation = none

find /etc/ssh/sshd_config* -type f -print0 | xargs -0 sed -i '/^(Allow|Deny)(Users|Groups).*/d'
echo "AllowGroups " >> /etc/ssh/sshd_config
echo "DenyGroups " >> /etc/ssh/sshd_config
