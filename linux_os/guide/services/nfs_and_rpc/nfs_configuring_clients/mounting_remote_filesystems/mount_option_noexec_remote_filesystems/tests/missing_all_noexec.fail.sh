#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig

cp $SHARED/fstab /etc/
sed -i 's/,noexec//' /etc/fstab
