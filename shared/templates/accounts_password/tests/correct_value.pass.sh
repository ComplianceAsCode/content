#!/bin/bash
# variables = var_password_pam_{{{ VARIABLE }}}={{{ TEST_VAR_VALUE }}}

{{% if product == "ubuntu2404" %}}
{{{ bash_pam_pwquality_enable() }}}
{{% endif %}}

truncate -s 0 /etc/security/pwquality.conf

echo "{{{ VARIABLE }}} = {{{ TEST_CORRECT_VALUE }}}" >> /etc/security/pwquality.conf
