#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S

# Remediating would mount /tmp, which would break the test environment.
# remediation = none

. $SHARED/partition.sh

create_partition

make_fstab_correct_partition_line /tmp

# $SHARED/fstab is correct, but we are not mounted.
