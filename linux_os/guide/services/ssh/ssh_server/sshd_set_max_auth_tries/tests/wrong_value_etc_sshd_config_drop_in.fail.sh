#!/bin/bash
# platform = SUSE Linux Enterprise 16
# variables = sshd_max_auth_tries_value=4
source include.sh

echo "MaxAuthTries 20" >> /etc/ssh/sshd_config.d/01-complianceascode.conf
