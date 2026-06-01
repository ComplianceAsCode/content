#!/bin/bash
# platform = SUSE Linux Enterprise 16
# variables = sshd_max_auth_tries_value=4
source include.sh

echo "MaxAuthTries 5" >> /usr/etc/ssh/sshd_config
