#!/bin/bash
# variables = var_password_pam_{{{ VARIABLE }}}={{{ TEST_VAR_VALUE }}}


# This test will ensure that the remediation also applies the configuration in 
# /etc/security/pwquality.conf.d/*.conf files

truncate -s 0 /etc/security/pwquality.conf

echo "{{{ VARIABLE }}} = {{{ TEST_WRONG_VALUE }}}" \
>> /etc/security/pwquality.conf.d/test_file.conf
