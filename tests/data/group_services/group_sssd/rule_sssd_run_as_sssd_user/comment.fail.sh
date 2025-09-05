#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp

yum -y install /usr/lib/systemd/system/sssd.service
systemctl enable sssd
mkdir -p /etc/sssd/conf.d
echo -e "[sssd]\n# user = sssd" >> /etc/sssd/conf.d/ospp.conf
chmod 600 /etc/sssd/conf.d/ospp.conf
