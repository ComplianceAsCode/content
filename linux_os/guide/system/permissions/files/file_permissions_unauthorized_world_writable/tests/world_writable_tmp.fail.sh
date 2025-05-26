#!/bin/bash
# platform = multi_platform_ubuntu

find / -xdev -type f -perm -002 -exec chmod o-w {} \;

mount tmpfs /tmp -t tmpfs

touch /tmp/test
chmod o+w /tmp/test
