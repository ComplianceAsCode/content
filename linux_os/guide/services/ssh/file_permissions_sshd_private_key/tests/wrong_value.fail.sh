#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chmod 0777 $FAKE_KEY
