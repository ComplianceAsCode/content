#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_pci-dss

# verify (-V) all installed (-a) packages digests,
# if digest differs from package metadata, then attribute '5' is printed
result=$(rpm -Va --noconfig | grep -E '^..5')

[ -z "$result" ]
