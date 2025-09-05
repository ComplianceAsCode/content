#!/bin/bash
# platform = multi_platform_ubuntu

groupadd -r sys_group_test

find -P /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin \! -group root -type f -exec chgrp --no-dereference sys_group_test '{}' \; || true
