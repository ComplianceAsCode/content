#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp

# We will configure user to be sssd

yum -y install /usr/lib/systemd/system/sssd.service
systemctl enable sssd
mkdir -p /etc/sssd/conf.d
echo -e "[sssd]\nuser = sssd" >> /etc/sssd/conf.d/ospp.conf
chmod 600 /etc/sssd/conf.d/ospp.conf
