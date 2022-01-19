#!/bin/bash
# packages = authconfig
# platform = multi_platform_fedora,Red Hat Enterprise Linux 7
# variables = var_accounts_passwords_pam_faillock_unlock_time=600

authconfig --enablefaillock --faillockargs="unlock_time=600" --update
