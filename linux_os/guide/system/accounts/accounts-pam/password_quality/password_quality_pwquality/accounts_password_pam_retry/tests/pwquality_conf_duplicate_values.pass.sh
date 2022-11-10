#!/bin/bash
# variables = var_password_pam_retry=3

source common.sh

CONF_FILE="/etc/security/pwquality.conf"
retry_cnt=3

truncate -s 0 $CONF_FILE

echo "retry = 3" >> $CONF_FILE
echo "retry = 3" >> $CONF_FILE
