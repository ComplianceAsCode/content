#!/bin/bash
# platform = multi_platform_all
# remediation = none

awk -F':' '{if ($3>={{{ uid_min }}} && $3!= {{{ nobody_uid }}}) print $1}' /etc/passwd \
        | xargs -I{} userdel -r {}

mkdir -p /root_home
useradd -m -d /root_home/testUser1 testUser1
