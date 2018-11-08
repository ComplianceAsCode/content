#!/bin/bash
# 
# profiles = xccdf_org.ssgproject.content_profile_standard
# We don't remediate anything if the config file is missing completely.
# remediation = none

BIND_CONF='/etc/named.conf'

rm -f "$BIND_CONF"
