#!/bin/bash
# platform = SUSE Linux Enterprise 16
source include.sh

echo "LoginGraceTime 61" >> /etc/ssh/sshd_config.d/01-complianceascode.conf
