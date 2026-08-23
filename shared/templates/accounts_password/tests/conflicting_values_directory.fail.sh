#!/bin/bash
# This test only applies to platforms that check the pwquality.conf.d directory
# platform = Oracle Linux 8,Oracle Linux 9,multi_platform_rhel
# variables = var_password_pam_{{{ VARIABLE }}}={{{ TEST_VAR_VALUE }}}

truncate -s 0 "{{{ pwquality_path }}}"

echo "{{{ VARIABLE }}} = {{{ TEST_CORRECT_VALUE }}}" >> "{{{ pwquality_path }}}"

config_dir="/etc/security/pwquality.conf.d"
mkdir -p $config_dir
echo "{{{ VARIABLE }}} = {{{ TEST_WRONG_VALUE }}}" >> $config_dir/test_file.conf
