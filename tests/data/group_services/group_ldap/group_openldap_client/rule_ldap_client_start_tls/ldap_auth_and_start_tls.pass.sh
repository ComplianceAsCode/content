#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp-rhel7

AUTHCONFIG_REGEX="^[[:space:]]*USELDAPAUTH=yes[[:space:]]*$"
grep -q "$AUTHCONFIG_REGEX" /etc/sysconfig/authconfig && \
	sed -i "s/$AUTHCONFIG_REGEX/USELDAPAUTH=yes/" /etc/sysconfig/authconfig || \
	echo "USELDAPAUTH=yes" >> /etc/sysconfig/authconfig

yum install -y nss-pam-ldapd

START_TLS_REGEX="^[[:space:]]*ssl[[:space:]]*start_tls[[:space:]]*$"
grep -q "$START_TLS_REGEX" /etc/nslcd.conf && \
	sed -i "s/$START_TLS_REGEX/ssl start_tls/" /etc/nslcd.conf || \
	echo "ssl start_tls" >> /etc/nslcd.conf
