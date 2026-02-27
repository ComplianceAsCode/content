#!/bin/bash
# platform = SUSE Linux Enterprise 16
# variables = sshd_max_auth_tries_value=4
source include.sh

touch /etc/ssh/sshd_config
echo "MaxAuthTries 4" >> /usr/etc/ssh/sshd_config
