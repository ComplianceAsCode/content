#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora

authselect create-profile hardening -b sssd
CUSTOM_PROFILE="custom/hardening"
authselect select $CUSTOM_PROFILE --force

CUSTOM_SYSTEM_AUTH="/etc/authselect/$CUSTOM_PROFILE/system-auth"
{{% if product == "rhel8" or product == "rhel9" %}}
sed -i --follow-symlinks '/^password\s*required\s*pam_pwquality\.so/d' $CUSTOM_SYSTEM_AUTH
{{% else %}}
sed -i --follow-symlinks '/^password\s*requisite\s*pam_pwquality\.so/d' $CUSTOM_SYSTEM_AUTH
{{% endif %}}
authselect apply-changes -b
