#!/bin/bash
# packages = authconfig
# platform = multi_platform_fedora,Red Hat Enterprise Linux 7
# variables = var_accounts_passwords_pam_faillock_deny=3

authconfig --enablefaillock --faillockargs="deny=5" --update
