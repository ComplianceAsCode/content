#!/bin/bash
# platform = multi_platform_all
# remediation = none

. $SHARED/partition.sh

{{{ bash_remove_interactive_users_from_passwd_by_uid() }}}

umount /srv || true

clean_up_partition /srv

create_partition

make_fstab_correct_partition_line /srv

mount_partition /srv

mkdir -p /srv/home
useradd -m -d /srv/home/testUser1 testUser1

mkdir -p /root_home
useradd -m -d /root_home/testUser2 testUser2
