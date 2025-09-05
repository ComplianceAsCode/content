#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp
SSHD_CONFIG="/etc/ssh/sshd_config"

. "$SHARED/utilities.sh"

# OSPP profile selects a time out of 14_minutes
assert_directive_in_file "$SSHD_CONFIG" ClientAliveInterval "ClientAliveInterval 840"
assert_directive_in_file "$SSHD_CONFIG" ClientAliveCountMax "ClientAliveCountMax 0"
