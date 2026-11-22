#!/bin/bash
# platform = Oracle Linux 8,Oracle Linux 9,multi_platform_rhel,multi_platform_fedora
# profiles = ospp
# packages = crypto-policies-scripts

update-crypto-policies --set "FIPS:OSPP"

unlink "/etc/crypto-policies/back-ends/nss.config"
rm -f "/etc/crypto-policies/back-ends/nss.config"
