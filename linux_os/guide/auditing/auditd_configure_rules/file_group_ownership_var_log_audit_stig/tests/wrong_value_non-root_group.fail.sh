#!/bin/bash
# packages = audit

source common.sh

echo "log_group = group_test" >> /etc/audit/auditd.conf
echo "log_file = ${FILE2}" >> /etc/audit/auditd.conf

chgrp root ${FILE1}
chgrp root ${FILE2}
