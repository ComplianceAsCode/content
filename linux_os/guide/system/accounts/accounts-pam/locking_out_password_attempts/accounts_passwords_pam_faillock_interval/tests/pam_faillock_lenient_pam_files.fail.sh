#!/bin/bash
# packages = authconfig
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7,multi_platform_fedora
# variables = var_accounts_passwords_pam_faillock_fail_interval=900

authconfig --enablefaillock --faillockargs="fail_interval=300" --update
