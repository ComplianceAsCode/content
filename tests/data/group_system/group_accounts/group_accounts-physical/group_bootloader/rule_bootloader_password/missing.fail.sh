#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa
# remediation = none

. grub-passwords.sh

remove_grub_password || true
