#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp

echo "auth  sufficient  pam_unix.so try_first_pass nullok" >> /etc/pam.d/system-auth
