#!/bin/bash
# remediation = None

find /etc/ssh/sshd_config* -type f -print0 | xargs -0 sed -i '/^(Allow|Deny)(Users|Groups).*/d'
echo "AllowUsers testuser1 testuser2 testuser3" >> /etc/ssh/sshd_config
