#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chmod 0640 /etc/ssh/*_key
