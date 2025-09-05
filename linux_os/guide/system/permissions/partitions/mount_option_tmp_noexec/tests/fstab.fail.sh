#!/bin/bash

. $SHARED/partition.sh

clean_up_partition /tmp

create_partition

make_fstab_given_partition_line /tmp ext2 nodev

mount_partition /tmp
