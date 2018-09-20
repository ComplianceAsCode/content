#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp

yum -y install dconf

# It is ok if string is not found in any file
file=$(grep -R "lock-enabled" /etc/dconf/db/local.d) || true
if [ -n "$file" ] ; then
    sed -i "/^lock-enabled=.*/d" $file
fi
