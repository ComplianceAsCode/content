#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig

rm -f /etc/login.defs
echo "PASS_MAX_DAYS        60" > /etc/login.defs
