#!/bin/bash
# platform = Red Hat Virtualization 4,multi_platform_fedora
# packages = pam

config_file=/etc/pam.d/system-auth

sed -i --follow-symlinks '/^password\s*requisite\s*pam_pwquality\.so/d' $config_file
