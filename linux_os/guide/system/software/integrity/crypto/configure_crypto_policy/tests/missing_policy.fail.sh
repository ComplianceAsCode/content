#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# profiles = xccdf_org.ssgproject.content_profile_ospp, xccdf_org.ssgproject.content_profile_standard
# packages = crypto-policies-scripts

sed -i "1d" /etc/crypto-policies/config
