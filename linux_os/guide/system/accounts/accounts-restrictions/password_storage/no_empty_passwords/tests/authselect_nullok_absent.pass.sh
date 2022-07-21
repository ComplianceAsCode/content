#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora

SYSTEM_AUTH_FILE="/etc/pam.d/system-auth"

authselect select sssd --force
authselect enable-feature without-nullok
authselect apply-changes
