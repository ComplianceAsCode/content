#!/bin/bash
# platform = multi_platform_rhel,multi_platform_ol

rm -f /etc/pam.d/postlogin
echo "session required pam_lastlog.so showfailed" >> /etc/pam.d/postlogin
