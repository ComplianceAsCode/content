#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S

. partition.sh

create_partition

make_fstab_correct_partition_line /var/tmp

# fstab is correct, but we are not mounted.
