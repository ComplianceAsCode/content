#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_stig

SSSD_CONF="/etc/sssd/sssd.conf"

yum -y install /usr/lib/systemd/system/sssd.service
rm -rf /etc/sssd/conf.d/
rm -f SSSD_CONF
cat <<EOF > $SSSD_CONF
[sssd]
services = nss,pam
[pam]
example1 = abc
EOF
