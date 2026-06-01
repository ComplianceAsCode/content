#!/bin/bash
# platform = SUSE Linux Enterprise 16
source include.sh

echo "LoginGraceTime 60" >> /usr/etc/ssh/sshd_config.d/01-complianceascode.conf
