#!/bin/bash

. $SHARED/partition.sh

clean_up_partition /var/tmp

create_partition

make_fstab_correct_partition_line /var/tmp

# $SHARED/fstab is correct, but we are not mounted.
