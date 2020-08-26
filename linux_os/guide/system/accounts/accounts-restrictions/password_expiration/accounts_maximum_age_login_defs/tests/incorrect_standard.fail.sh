#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_standard

rm -f /etc/login.defs
echo "PASS_MAX_DAYS 120" > /etc/login.defs
