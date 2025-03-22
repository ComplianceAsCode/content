#!/bin/bash

find /etc/ssh/sshd_config* -type f -print0 | xargs -0 sed -i '/^(Allow|Deny)(Users|Groups).*/d'
echo "AllowUsers testuser1 testuser2 testuser3" >> /etc/ssh/sshd_config
echo "AllowGroups testgroup1 testgroup2 testgroup3" >> /etc/ssh/sshd_config
