#!/bin/bash

. $SHARED/partition.sh

clean_up_partition /dev/shm

create_partition

make_fstab_given_partition_line /dev/shm ext2 noexec

mount_partition /dev/shm
