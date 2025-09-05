#!/bin/bash
# platform=Ubuntu 20.04

cp -f common-account_pam_config_configured /etc/pam.d/common-account
cp -f common-auth_pam_config_zero_deny /etc/pam.d/common-auth
