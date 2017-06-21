#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S

. partition.sh
mount $PARTITION /var/tmp
echo "$PARTITION     /var/tmp     none     rw,nodev,noexec,nosuid,bind     0 0" >> /etc/fstab
