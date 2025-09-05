#!/bin/bash

. $SHARED/partition.sh

clean_up_partition /home

create_partition

make_fstab_given_partition_line /home ext2 noexec

mount_partition /home
