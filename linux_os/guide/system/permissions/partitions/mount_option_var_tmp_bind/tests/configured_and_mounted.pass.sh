#!/bin/bash

. $SHARED/partition.sh

# Make sure scenario preparation starts from a clean state
clean_up_partition /var/tmp

# Redefine PARTITION variable defined in $SHARED/partition.sh
PARTITION="/tmp"
make_fstab_bind_partition_line /var/tmp

mount_bind_partition /var/tmp
