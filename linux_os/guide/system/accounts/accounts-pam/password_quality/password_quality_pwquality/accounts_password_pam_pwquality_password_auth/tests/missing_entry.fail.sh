#!/bin/bash
# platform = Oracle Linux 7,Red Hat Virtualization 4,multi_platform_fedora
# packages = pam

config_file=/etc/pam.d/password-auth

sed -i --follow-symlinks '/^password\s*requisite\s*pam_pwquality\.so/d' $config_file
