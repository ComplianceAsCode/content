#!/bin/bash
# platform = Red Hat Enterprise Linux 8
# profiles = xccdf_org.ssgproject.content_profile_ospp

update-crypto-policies --set "FIPS:OSPP"

rm -f "/etc/crypto-policies/back-ends/nss.config"
