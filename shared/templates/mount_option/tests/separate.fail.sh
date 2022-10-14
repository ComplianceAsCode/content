#!/bin/bash
{{% if MOUNT_HAS_TO_EXIST == "no" %}}
# platform = multi_platform_example
{{% else %}}
# platform = multi_platform_all
{{% endif %}}
. $SHARED/partition.sh

clean_up_partition {{{ MOUNTPOINT }}}

create_partition

make_fstab_correct_partition_line {{{ MOUNTPOINT }}}

# $SHARED/fstab is correct, but we are not mounted.
