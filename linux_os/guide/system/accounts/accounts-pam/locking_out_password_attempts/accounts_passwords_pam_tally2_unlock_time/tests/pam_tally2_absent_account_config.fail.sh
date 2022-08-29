#!/bin/bash
# platform = multi_platform_sle,Ubuntu 20.04

cp -f common-account_pam_tally2_absent /etc/pam.d/common-account
cp -f common-auth_pam_tally2_unlock_time_configured /etc/pam.d/common-auth
