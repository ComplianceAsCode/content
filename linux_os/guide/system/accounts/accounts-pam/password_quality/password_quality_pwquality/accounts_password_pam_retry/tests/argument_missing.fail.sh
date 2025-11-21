#!/bin/bash
# platform = Red Hat Virtualization 4,multi_platform_almalinux,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_ubuntu
# variables = var_password_pam_retry=3
{{% if 'ol' in families %}}
# packages = authselect
{{% elif product in ['sle15', 'sle16'] %}}
# packages = libpwquality1
{{% endif %}}

source common.sh
