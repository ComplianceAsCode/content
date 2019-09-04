#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp
SYSTEM_AUTH_FILE="/etc/pam.d/system-auth"

sed -i '/nullok/d' $SYSTEM_AUTH_FILE
echo "auth  sufficient  pam_unix.so nullok_secure" >> $SYSTEM_AUTH_FILE
