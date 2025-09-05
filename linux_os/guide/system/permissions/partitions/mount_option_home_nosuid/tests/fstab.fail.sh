#!/bin/bash
{{% if "ol" in product %}}
# platform = multi_platform_example
{{% else %}}
# platform = multi_platform_all
{{% endif %}}

. $SHARED/partition.sh

umount /home || true  # no problem if not mounted

clean_up_partition /home

create_partition

make_fstab_given_partition_line /home ext2 nodev

mount_partition /home
