#!/bin/bash
# platform = SUSE Linux Enterprise 16
source include.sh

echo "LoginGraceTime 60" >> "{{{ sshd_config_dir }}}/01-complianceascode-reinforce-os-defaults.conf"
