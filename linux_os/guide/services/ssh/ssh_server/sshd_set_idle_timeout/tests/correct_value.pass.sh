#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp
SSHD_CONFIG="/etc/ssh/sshd_config"

. "$SHARED/utilities.sh"

# RHEL8 OSPP profile selects a timeout interval of 14_minutes
# while RHEL7 OSPP has 10_minutes so we go with some lower value
# to satisfy both profiles.
assert_directive_in_file "$SSHD_CONFIG" ClientAliveInterval "ClientAliveInterval 500"
assert_directive_in_file "$SSHD_CONFIG" ClientAliveCountMax "ClientAliveCountMax 0"
