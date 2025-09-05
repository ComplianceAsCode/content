#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_pci-dss

# verify (-V) all installed (-a) packages digests,
# if digest differs from package metadata, then attribute '5' is printed
result=$(rpm -Va | grep -E '^..5.* /(bin|sbin|lib|lib64|usr)/')

[ -z "$result" ]
