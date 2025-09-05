#!/bin/bash
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# profiles = xccdf_org.ssgproject.content_profile_ospp
# packages = crypto-policies-scripts

update-crypto-policies --set "FIPS:OSPP"
