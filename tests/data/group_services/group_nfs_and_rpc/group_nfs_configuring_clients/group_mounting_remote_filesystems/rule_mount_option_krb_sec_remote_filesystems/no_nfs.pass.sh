#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig

cp ../fstab /etc/
sed -i '/nfs/d' /etc/fstab
