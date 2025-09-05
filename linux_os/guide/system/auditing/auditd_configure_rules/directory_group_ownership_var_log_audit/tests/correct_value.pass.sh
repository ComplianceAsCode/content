#!/bin/bash
# packages = audit

sed -i "/\s*log_group.*/d" /etc/audit/auditd.conf
sed -i "/\s*log_file.*/d" /etc/audit/auditd.conf
echo "log_group = root" >> /etc/audit/auditd.conf
chgrp root /var/log/audit
