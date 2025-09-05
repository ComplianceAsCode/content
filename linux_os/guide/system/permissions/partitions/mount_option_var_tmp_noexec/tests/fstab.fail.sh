#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S

. $SHARED/partition.sh

clean_up_partition /var/tmp

create_partition

make_fstab_given_partition_line /var/tmp ext2 nodev

mount_partition /var/tmp
