#!/bin/bash
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# profiles = xccdf_org.ssgproject.content_profile_ospp

update-crypto-policies --set "FIPS:OSPP"

rm -f "/etc/crypto-policies/back-ends/nss.config"
