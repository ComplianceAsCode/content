#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig

echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
chmod 440 /etc/sudoers

mkdir /etc/sudoers.d/
echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/sudoers
chmod 440 /etc/sudoers.d/sudoers
