#!/bin/bash
# packages = nss-pam-ldapd
#


sed -i "/$START_TLS_REGEX/d" /etc/nslcd.conf || true
