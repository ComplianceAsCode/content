#!/bin/bash
# packages = authselect
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# variables = var_password_pam_retry=3

CONF_FILE="/etc/security/pwquality.conf"
sed -i "/^.*retry\s*=.*/d" "$CONF_FILE"

authselect select minimal --force
{{{ bash_remove_pam_module_option_configuration('/etc/pam.d/system-auth', 'password', '', 'pam_pwquality.so', 'retry') }}}
{{{ bash_remove_pam_module_option_configuration('/etc/pam.d/password-auth', 'password', '', 'pam_pwquality.so', 'retry') }}}
