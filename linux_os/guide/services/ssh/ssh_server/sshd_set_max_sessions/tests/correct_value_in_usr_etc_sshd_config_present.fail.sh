#!/bin/bash
# platform = SUSE Linux Enterprise 16
# variables = var_sshd_max_sessions=4
source include.sh

touch /etc/ssh/sshd_config
echo "MaxSessions 4" >> /usr/etc/ssh/sshd_config
