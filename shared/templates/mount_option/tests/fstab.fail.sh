#!/bin/bash

. $SHARED/partition.sh

clean_up_partition {{{ MOUNTPOINT }}}

create_partition

{{% if MOUNTOPTION == "noexec" %}}
{{% set mount_option = "nosuid" %}}
{{% else %}}
{{% set mount_option = "noexec" %}}
{{% endif %}}


make_fstab_given_partition_line {{{ MOUNTPOINT }}} ext2 {{{ mount_option }}}

mount_partition {{{ MOUNTPOINT }}}
