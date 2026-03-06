#!/bin/bash
# variables = var_password_pam_{{{ VARIABLE }}}={{{ TEST_VAR_VALUE }}}

{{% if product in ["sle15", "sle16"] %}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/common-password', 'password', 'required', 'pam_pwquality.so', '', '', '') }}}
{{% endif %}}

truncate -s 0 "{{{ pwquality_path }}}"

echo "#{{{ VARIABLE }}} = {{{ TEST_CORRECT_VALUE }}}" >> "{{{ pwquality_path }}}"
