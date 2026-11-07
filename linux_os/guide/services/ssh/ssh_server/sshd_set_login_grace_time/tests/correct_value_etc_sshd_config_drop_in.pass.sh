#!/bin/bash
# platform = SUSE Linux Enterprise 16
source include.sh
{{{ bash_copy_distro_defaults("/usr/etc/ssh/sshd_config", sshd_main_config_file) }}}
echo "LoginGraceTime 60" >> "{{{ sshd_config_dir }}}/01-complianceascode-reinforce-os-defaults.conf"
