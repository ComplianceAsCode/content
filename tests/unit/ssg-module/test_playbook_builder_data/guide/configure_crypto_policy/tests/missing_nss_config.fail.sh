#!/bin/bash
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# profiles = xccdf_org.ssgproject.content_profile_ospp
# packages = crypto-policies-scripts

update-crypto-policies --set "FIPS:OSPP"

unlink "/etc/crypto-policies/back-ends/nss.config"
rm -f "/etc/crypto-policies/back-ends/nss.config"
