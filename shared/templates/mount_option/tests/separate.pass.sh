#!/bin/bash

# platform = multi_platform_all
. $SHARED/partition.sh

clean_up_partition {{{ MOUNTPOINT }}}

create_partition

make_fstab_given_partition_line {{{ MOUNTPOINT }}} ext2 {{{ MOUNTOPTION }}}
{{{ bash_systemctl_daemon_reload() }}}

# $SHARED/fstab is correct, but we are not mounted.
