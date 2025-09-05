#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S

. ../partition.sh

create_partition

make_fstab_given_partition_line /tmp ext2 nodev

mount_partition /tmp
