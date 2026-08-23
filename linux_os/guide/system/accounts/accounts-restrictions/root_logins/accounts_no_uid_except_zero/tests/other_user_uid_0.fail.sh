#!/bin/bash
# platform = multi_platform_all
#

useradd --non-unique --uid 0 root2
# configure password, otherwise user is locked
echo "root2:password" | chpasswd
