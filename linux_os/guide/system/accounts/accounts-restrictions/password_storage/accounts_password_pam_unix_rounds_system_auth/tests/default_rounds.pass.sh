#!/bin/bash
# platform = Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_wrlinux
# packages = pam

pamFile="/etc/pam.d/system-auth"

# Make sure rounds is not set.
sed -iP --follow-symlinks "/password[[:space:]]\+sufficient[[:space:]]\+pam_unix\.so/ \
                                s/rounds=[[:digit:]]\+//" $pamFile
