#!/bin/bash
# platform = multi_platform_fedora,Oracle Linux 8,Oracle Linux 9,multi_platform_rhel
# profiles = xccdf_org.ssgproject.content_profile_ospp, xccdf_org.ssgproject.content_profile_standard
# packages = crypto-policies-scripts

sed -i "1d" /etc/crypto-policies/config
