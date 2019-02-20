#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp

yum -y install dconf

mkdir -p /etc/dconf/profile
echo "service-db:keyfile/user" > /etc/dconf/profile/user
echo "system-db:local" >> /etc/dconf/profile/user
