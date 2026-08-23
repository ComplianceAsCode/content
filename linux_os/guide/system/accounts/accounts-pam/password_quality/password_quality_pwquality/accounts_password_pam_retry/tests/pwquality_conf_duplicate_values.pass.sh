#!/bin/bash
# packages = authselect
# platform = multi_platform_rhel
# variables = var_password_pam_retry=3

source common.sh

CONF_FILE="{{{ pwquality_path }}}"
retry_cnt=3

truncate -s 0 $CONF_FILE

echo "retry = 3" >> $CONF_FILE
echo "retry = 3" >> $CONF_FILE
