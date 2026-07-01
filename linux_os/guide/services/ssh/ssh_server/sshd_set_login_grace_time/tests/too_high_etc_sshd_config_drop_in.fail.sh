#!/bin/bash
# platform = SUSE Linux Enterprise 16
source include.sh

echo "LoginGraceTime 61" >> "{{{ sshd_config_dir }}}/01-complianceascode.conf"
