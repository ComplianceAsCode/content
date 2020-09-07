#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_e8

rm -f /etc/sudoers
echo "%wheel	ALL=(ALL)	ALL" > /etc/sudoers
echo "Defaults authenticate" > /etc/sudoers
chmod 440 /etc/sudoers
