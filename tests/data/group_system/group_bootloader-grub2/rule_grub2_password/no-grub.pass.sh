#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_stig

. grub-passwords.sh

rm -f "$GRUB_CFG_ROOT/grub.cfg"
