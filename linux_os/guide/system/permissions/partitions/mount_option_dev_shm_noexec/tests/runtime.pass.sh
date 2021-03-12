#!/bin/bash

. $SHARED/partition.sh

clean_up_partition /dev/shm

create_partition

make_fstab_correct_partition_line /dev/shm

mount_partition /dev/shm
