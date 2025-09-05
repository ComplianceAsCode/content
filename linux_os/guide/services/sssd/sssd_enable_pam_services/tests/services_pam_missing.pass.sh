#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_stig

SSSD_SERVICES_REGEX_SHORT="^[[:space:]]*services.*$"
SSSD_CONF="/etc/sssd/sssd.conf"

yum -y install /usr/lib/systemd/system/sssd.service
rm -rf /etc/sssd/conf.d/
rm -f SSSD_CONF
cat <<EOF > $SSSD_CONF
[sssd]
section1 = key
section2 = nss
[pam]
example1 = abc
EOF
