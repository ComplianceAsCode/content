#!/bin/bash
# This test only applies to platforms that check system-auth to not override
# the value in pwquality.conf
# platform = multi_platform_ol
# variables = var_password_pam_{{{ VARIABLE }}}={{{ TEST_VAR_VALUE }}}

truncate -s 0 "{{{ pwquality_path }}}"

echo "{{{ VARIABLE }}} = {{{ TEST_CORRECT_VALUE }}}" >> "{{{ pwquality_path }}}"

{{{
    bash_ensure_pam_module_configuration('/etc/pam.d/system-auth',
                                  'password',
                                  'required',
                                  'pam_pwquality.so',
                                  VARIABLE,
                                  TEST_CORRECT_VALUE)
}}}
