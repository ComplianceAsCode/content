#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_pci-dss

# verify (-V) all installed (-a) packages permissions,
# if permissions differs from package metadata, then attribute 'M' is printed
result=$(rpm -Va | grep '^.M')

[ -z "$result" ]
