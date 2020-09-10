#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig

rm -f /etc/sudoers
echo "%wheel	ALL=(ALL)	ALL" > /etc/sudoers
chmod 440 /etc/sudoers
