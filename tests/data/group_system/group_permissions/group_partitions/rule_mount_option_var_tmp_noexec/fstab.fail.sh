#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S

. partition.sh

create_partition

make_fstab_given_partition_line /var/tmp nodev

mount_partition /var/tmp
