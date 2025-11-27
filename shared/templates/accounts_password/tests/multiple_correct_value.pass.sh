#!/bin/bash
# This test only applies to platforms that check the pwquality.conf.d directory
# platform = Oracle Linux 8, Oracle Linux 9
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

{{% if product in ["sle15", "sle16"] %}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/common-password', 'password', 'required', 'pam_pwquality.so', '', '', '') }}}
{{% endif %}}

truncate -s 0 "{{{ pwquality_path }}}"

echo "{{{ VARIABLE }}} = {{{ TEST_CORRECT_VALUE }}}" >> "{{{ pwquality_path }}}"

config_dir="/etc/security/pwquality.conf.d"
mkdir -p $config_dir
echo "{{{ VARIABLE }}} = {{{ TEST_CORRECT_VALUE }}}" >> $config_dir/test_file.conf
