#!/bin/bash
# This test only applies to platforms that check the pwquality.conf.d directory
# platform = Oracle Linux 8,Oracle Linux 9,multi_platform_rhel
# variables = var_password_pam_{{{ VARIABLE }}}={{{ TEST_VAR_VALUE }}}

# This test will ensure that OVAL also checks the configuration in
# /etc/security/pwquality.conf.d/*.conf files

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

config_dir="/etc/security/pwquality.conf.d"
mkdir -p $config_dir
echo "{{{ VARIABLE }}} = {{{ TEST_CORRECT_VALUE }}}" >> $config_dir/test_file.conf
