#!/bin/bash
# platform = multi_platform_all

. $SHARED/partition.sh

{{{ bash_remove_interactive_users_from_passwd_by_uid() }}}

umount /srv || true

clean_up_partition /srv

create_partition

make_fstab_correct_partition_line /srv

mount_partition /srv

mkdir -p /srv/home
useradd -m -d /srv/home/testUser1 testUser1
