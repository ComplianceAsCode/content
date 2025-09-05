#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

yum install -y nss-pam-ldapd

sed -i "/$START_TLS_REGEX/d" /etc/nslcd.conf || true
