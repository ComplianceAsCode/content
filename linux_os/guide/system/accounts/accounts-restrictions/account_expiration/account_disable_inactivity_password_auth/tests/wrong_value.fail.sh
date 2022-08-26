#!/bin/bash
# packages = authselect,pam
# variables = var_account_disable_inactivity=35

source common.sh

sed -i '/^\s*auth.*sufficient.*pam_unix\.so/i auth required pam_lastlog.so inactive=36' $CUSTOM_PAM_FILE

authselect apply-changes
