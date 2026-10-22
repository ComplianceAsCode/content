#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora
# remediation = none

SYSTEM_AUTH_FILE="/etc/pam.d/system-auth"

# This modification will break the integrity checks done by authselect.
{{% if product == "rhel8" or product == "rhel9" %}}
sed -i --follow-symlinks -e '/^password\s*required\s*pam_pwquality\.so/ s/^#*/#/g' $SYSTEM_AUTH_FILE
{{% else %}}
sed -i --follow-symlinks -e '/^password\s*requisite\s*pam_pwquality\.so/ s/^#*/#/g' $SYSTEM_AUTH_FILE
{{% endif %}}
