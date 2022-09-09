#!/bin/bash

# platform = multi_platform_all
. $SHARED/partition.sh

clean_up_partition {{{ MOUNTPOINT }}}

create_partition

{{% if MOUNTOPTION != "nodev" %}}
make_fstab_given_partition_line {{{ MOUNTPOINT }}} ext2 nodev
{{% else %}}
make_fstab_given_partition_line {{{ MOUNTPOINT }}} ext2 noexec
{{% endif %}}

mount_partition {{{ MOUNTPOINT }}}
