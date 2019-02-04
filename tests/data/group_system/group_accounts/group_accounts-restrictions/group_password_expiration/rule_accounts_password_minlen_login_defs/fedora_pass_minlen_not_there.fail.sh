#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_standard
# platform = multi_platform_fedora

sed -i "/^PASS_MIN_LEN.*/d" /etc/login.defs
