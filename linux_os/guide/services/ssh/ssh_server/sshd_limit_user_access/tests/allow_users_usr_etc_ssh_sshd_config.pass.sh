#!/bin/bash
# platform = SUSE Linux Enterprise 16
source common.sh

echo "AllowUsers testuser1 testuser2 testuser3" >> /usr/etc/ssh/sshd_config
