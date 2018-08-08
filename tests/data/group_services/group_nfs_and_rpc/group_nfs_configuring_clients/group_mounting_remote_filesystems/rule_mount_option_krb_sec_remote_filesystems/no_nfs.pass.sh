#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa

cp ../fstab /etc/
sed -i '/nfs/d' /etc/fstab
