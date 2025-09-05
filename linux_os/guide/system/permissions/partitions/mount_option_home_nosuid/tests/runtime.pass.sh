#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig

. $SHARED/partition.sh

umount /home || true  # no problem if not mounted

clean_up_partition /home

create_partition

make_fstab_correct_partition_line /home

mount_partition /home
