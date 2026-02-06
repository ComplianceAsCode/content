#!/bin/bash
# platform = multi_platform_all
# remediation = none

. $SHARED/partition.sh

awk -F':' '{if ($3>={{{ uid_min }}} && $3!= {{{ nobody_uid }}}) print $1}' /etc/passwd \
        | xargs -I{} userdel -r {}

umount /srv || true

clean_up_partition /srv

create_partition

make_fstab_correct_partition_line /srv

mount_partition /srv

mkdir -p /srv/home
useradd -m -d /srv/home/testUser1 testUser1

mkdir -p /root_home
useradd -m -d /root_home/testUser2 testUser2
