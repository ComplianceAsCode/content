#!/bin/bash
# platform = multi_platform_sle,Ubuntu 20.04

cp -f common-account_pam_tally2_configure /etc/pam.d/common-account
cp -f common-auth_pam_tally2_even_deny_root_configured /etc/pam.d/common-auth
