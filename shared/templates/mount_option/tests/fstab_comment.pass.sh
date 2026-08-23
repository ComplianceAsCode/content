#!/bin/bash

# platform = multi_platform_all
. $SHARED/partition.sh

clean_up_partition {{{ MOUNTPOINT }}}

create_partition

make_fstab_given_partition_line {{{ MOUNTPOINT }}} ext2 defaults
# comment last line added above to be ignored
sed -Ei '${s/^/#/}' /etc/fstab

make_fstab_given_partition_line {{{ MOUNTPOINT }}} ext2 {{{ MOUNTOPTION }}}

mount_partition {{{ MOUNTPOINT }}} || true
