#!/bin/bash
# platform = Oracle Linux 8,Oracle Linux 9,multi_platform_rhel
# profiles = xccdf_org.ssgproject.content_profile_ospp
# packages = crypto-policies-scripts

update-crypto-policies --set "FIPS:OSPP"
