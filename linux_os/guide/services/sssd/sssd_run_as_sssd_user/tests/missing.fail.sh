#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp

yum -y install /usr/lib/systemd/system/sssd.service
systemctl enable sssd
