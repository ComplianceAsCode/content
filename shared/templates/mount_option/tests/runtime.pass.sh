#!/bin/bash

# platform = multi_platform_all
. $SHARED/partition.sh

clean_up_partition {{{ MOUNTPOINT }}}

create_partition

make_fstab_correct_partition_line {{{ MOUNTPOINT }}}

mount_partition {{{ MOUNTPOINT }}}
