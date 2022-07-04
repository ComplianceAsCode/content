#!/bin/bash
# packages = authselect
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# variables = var_password_pam_retry=3

CONF_FILE="/etc/security/pwquality.conf"

retry_cnt=3
if grep -q "^.*retry\s*=" "$CONF_FILE"; then
	sed -i "s/^.*retry\s*=.*/retry = $retry_cnt/" "$CONF_FILE"
else
	echo "retry = $retry_cnt" >> "$CONF_FILE"
fi

authselect select minimal --force
{{{ bash_remove_pam_module_option_configuration('/etc/pam.d/system-auth', 'password', '', 'pam_pwquality.so', 'retry') }}}
{{{ bash_remove_pam_module_option_configuration('/etc/pam.d/password-auth', 'password', '', 'pam_pwquality.so', 'retry') }}}
