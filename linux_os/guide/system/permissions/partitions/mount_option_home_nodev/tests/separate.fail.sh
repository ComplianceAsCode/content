#!/bin/bash

. $SHARED/partition.sh

clean_up_partition /home

create_partition

make_fstab_correct_partition_line /home

# $SHARED/fstab is correct, but we are not mounted.
