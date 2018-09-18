#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S

. ../partition.sh

# Make sure scenario preparation starts from a clean state
clean_up_partition /var/tmp

# just mount the partition
mount -B /tmp /var/tmp
