#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S

. $SHARED/partition.sh

# Make sure scenario preparation starts from a clean state
clean_up_partition /var/tmp

# PARTITION is defined in $SHARED/partition.sh
mkdir -p "$PARTITION"
make_fstab_bind_partition_line /var/tmp

mount_bind_partition /var/tmp
