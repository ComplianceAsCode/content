#!/bin/bash
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_fedora

SYSTEM_AUTH_FILE="/etc/pam.d/system-auth"
PASSWORD_AUTH_FILE="/etc/pam.d/password-auth"

sed -i '/nullok/d' $SYSTEM_AUTH_FILE
sed -i '/nullok/d' $PASSWORD_AUTH_FILE
echo "# auth  sufficient  pam_unix.so try_first_pass nullok" >> $SYSTEM_AUTH_FILE
echo "# auth  sufficient  pam_unix.so try_first_pass nullok" >> $PASSWORD_AUTH_FILE
