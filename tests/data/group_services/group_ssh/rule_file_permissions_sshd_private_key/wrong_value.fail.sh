#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp-rhel7

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chmod 0777 $FAKE_KEY
