#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_cis

rm -f /etc/login.defs
echo "PASS_MAX_DAYS        365" > /etc/login.defs
