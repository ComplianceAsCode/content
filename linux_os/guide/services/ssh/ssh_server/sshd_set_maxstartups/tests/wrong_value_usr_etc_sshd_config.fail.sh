#!/bin/bash
# platform = SUSE Linux Enterprise 16
# variables = var_sshd_set_maxstartups=10:30:60
source include.sh

echo "MaxStartups 10:29:60" >> /usr/etc/ssh/sshd_config
