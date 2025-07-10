#!/bin/bash
# platform = multi_platform_ubuntu

groupadd -r sys_group_test

for SYSLIBDIRS in /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin
do
  find -P $SYSLIBDIRS \! -group root -type f -exec chgrp --no-dereference sys_group_test '{}' \;
done
