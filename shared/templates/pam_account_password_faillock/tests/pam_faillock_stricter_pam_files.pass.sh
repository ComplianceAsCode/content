#!/bin/bash
# packages = authconfig
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7,multi_platform_fedora
# variables = var_accounts_passwords_pam_faillock_deny=3

authconfig --enablefaillock --faillockargs="deny=2" --update
