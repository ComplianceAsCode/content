#!/bin/bash
# packages = audit
# platform = multi_platform_rhel

groupadd group_test

sed -i "/\s*log_group.*/d" /etc/audit/auditd.conf
echo "log_group = group_test" >> /etc/audit/auditd.conf

chgrp group_test /var/log/audit
