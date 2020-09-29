
# packages = /usr/lib/systemd/system/sssd.service
#!/bin/bash
#

rm -rf /etc/sssd/conf.d/
mkdir -p /etc/sssd/conf.d/
SSSD_CONF="/etc/sssd/conf.d/sssd.conf"

cp wrong_sssd.conf $SSSD_CONF

SSSD_CONF="/etc/sssd/sssd.conf"
cp wrong_sssd.conf $SSSD_CONF
