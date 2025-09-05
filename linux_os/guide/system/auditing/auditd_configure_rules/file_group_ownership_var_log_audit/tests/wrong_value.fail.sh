#!/bin/bash

sed -i "/\s*log_group.*/d" /etc/audit/auditd.conf
echo "log_group = root" >> /etc/audit/auditd.conf
touch /var/log/audit/audit.log.1
groupadd group_test
chgrp group_test /var/log/audit/audit.log.1
