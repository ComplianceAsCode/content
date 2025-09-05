#!/bin/bash

# Remediating would mount /tmp, which would break the test environment.
# remediation = none

. $SHARED/partition.sh

clean_up_partition /tmp

create_partition

make_fstab_correct_partition_line /tmp

# $SHARED/fstab is correct, but we are not mounted.
