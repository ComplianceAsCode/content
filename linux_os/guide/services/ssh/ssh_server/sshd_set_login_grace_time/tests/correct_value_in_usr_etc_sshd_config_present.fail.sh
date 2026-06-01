#!/bin/bash
# platform = SUSE Linux Enterprise 16
source include.sh

touch /etc/ssh/sshd_config
echo "LoginGraceTime 1" >> /usr/etc/ssh/sshd_config
