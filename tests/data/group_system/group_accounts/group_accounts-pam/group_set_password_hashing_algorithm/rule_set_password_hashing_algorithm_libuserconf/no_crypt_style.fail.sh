#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa

cp libuser.conf /etc/
sed -i "/crypt_style/d" /etc/libuser.conf
