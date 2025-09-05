#!/bin/bash
SYSTEM_AUTH_FILE="/etc/pam.d/system-auth"

echo "auth  sufficient  pam_unix.so try_first_pass nullok" >> $SYSTEM_AUTH_FILE
echo "auth  required    pam_unix.so nullok" >> $SYSTEM_AUTH_FILE
