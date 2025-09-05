#!/bin/bash
# packages = authconfig
# platform = multi_platform_fedora,Red Hat Enterprise Linux 7
# variables = var_accounts_passwords_pam_faillock_fail_interval=900

authconfig --enablefaillock --faillockargs="fail_interval=1200" --update
