#!/bin/bash
# variables = var_password_pam_{{{ VARIABLE }}}={{{ TEST_VAR_VALUE }}}
{{% if ZERO_COMPARISON_OPERATION is none %}}
# platform = Not Applicable
{{% endif %}}

truncate -s 0 /etc/security/pwquality.conf

echo "{{{ VARIABLE }}} = {{{ TEST_WRONG_VS_ZERO_VALUE }}}" >> /etc/security/pwquality.conf
