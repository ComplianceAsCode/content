#!/bin/bash
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# variables = var_password_pam_retry=3

CONF_FILE="/etc/security/pwquality.conf"

sed -i "/^.*retry\s*=.*/d" "$CONF_FILE"
