#!/bin/bash

. $SHARED/partition.sh

clean_up_partition /tmp

create_partition

make_fstab_correct_partition_line /tmp

mount_partition /tmp
