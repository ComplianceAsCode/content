#!/bin/bash
# platform = multi_platform_all

. $SHARED/partition.sh

mkdir -p /srv/home
awk -F':' '{if ($3>=1000 && $3!= 65534) print $1}' /etc/passwd \
        | xargs -I{} userdel -r {}

umount /srv || true  # no problem if not mounted

clean_up_partition /srv

create_partition

{{% if MOUNTOPTION != "nodev" %}}
make_fstab_given_partition_line /srv ext2 nodev
{{% else %}}
make_fstab_given_partition_line /srv ext2 noexec
{{% endif %}}

mount_partition /srv

mkdir -p /srv/home
useradd -m -d /srv/home/testUser1 testUser1
