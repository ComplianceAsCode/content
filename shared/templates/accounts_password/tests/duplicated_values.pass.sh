#!/bin/bash
# variables = var_password_pam_{{{ VARIABLE }}}={{{ TEST_VAR_VALUE }}}

{{% if product == "ubuntu2404" %}}
{{{ bash_pam_pwquality_enable() }}}
{{% endif %}}
{{% if "ol" in families %}}
{{{ bash_remove_pam_module_option_configuration('/etc/pam.d/system-auth',
                                  'password',
                                  '',
                                  'pam_pwquality.so',
                                  VARIABLE)
}}}
{{{ bash_remove_pam_module_option_configuration('/etc/pam.d/password-auth',
                                  'password',
                                  '',
                                  'pam_pwquality.so',
                                  VARIABLE)
}}}
{{% endif %}}

truncate -s 0 /etc/security/pwquality.conf

echo "{{{ VARIABLE }}} = {{{ TEST_CORRECT_VALUE }}}" >> /etc/security/pwquality.conf
echo "{{{ VARIABLE }}} = {{{ TEST_CORRECT_VALUE }}}" >> /etc/security/pwquality.conf
