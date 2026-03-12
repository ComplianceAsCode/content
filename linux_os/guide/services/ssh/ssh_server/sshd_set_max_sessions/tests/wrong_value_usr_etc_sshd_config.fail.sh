#!/bin/bash
# platform = SUSE Linux Enterprise 16
# variables = var_sshd_max_sessions=4
source include.sh

echo "MaxSessions 5" >> /usr/etc/ssh/sshd_config
