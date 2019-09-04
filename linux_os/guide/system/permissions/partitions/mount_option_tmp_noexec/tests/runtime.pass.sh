#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S

. $SHARED/partition.sh

create_partition

make_fstab_correct_partition_line /tmp

mount_partition /tmp
