#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S

. ../partition.sh

# PARTITION is defined in partition.sh
mkdir -p "$PARTITION"
make_fstab_bind_partition_line /var/tmp

mount_bind_partition /var/tmp
