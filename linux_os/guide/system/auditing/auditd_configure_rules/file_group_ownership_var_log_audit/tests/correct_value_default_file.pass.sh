#!/bin/bash
# packages = audit

source common.sh

echo "log_group = root" >> /etc/audit/auditd.conf

chgrp root ${FILE1}
chgrp group_test ${FILE2}
