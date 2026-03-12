#!/bin/bash
# platform = SUSE Linux Enterprise 16
# variables = var_sshd_set_maxstartups=10:30:60
source include.sh

touch /etc/ssh/sshd_config
echo "MaxStartups 10:30:60" >> /usr/etc/ssh/sshd_config
