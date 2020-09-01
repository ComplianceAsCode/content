#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_standard
# platform = multi_platform_fedora

rm -f /etc/login.defs
echo "PASS_MAX_DAYS 120" > /etc/login.defs
