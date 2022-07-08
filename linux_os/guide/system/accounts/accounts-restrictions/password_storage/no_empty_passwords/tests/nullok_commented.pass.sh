#!/bin/bash
# platform = Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol

SYSTEM_AUTH_FILE="/etc/pam.d/system-auth"

sed -i '/nullok/d' $SYSTEM_AUTH_FILE
echo "# auth  sufficient  pam_unix.so try_first_pass nullok" >> $SYSTEM_AUTH_FILE
