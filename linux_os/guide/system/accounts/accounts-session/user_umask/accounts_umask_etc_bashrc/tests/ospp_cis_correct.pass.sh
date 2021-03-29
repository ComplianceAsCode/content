#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_cis, xccdf_org.ssgproject.content_profile_ospp

sed -i '/umask/d' /etc/bashrc
echo "umask 027" >> /etc/bashrc
umask 027
