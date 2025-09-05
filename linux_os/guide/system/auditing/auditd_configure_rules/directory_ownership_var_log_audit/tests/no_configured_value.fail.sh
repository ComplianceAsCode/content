#!/bin/bash

sed -i "/\s*log_file.*/d" /etc/audit/auditd.conf

useradd testuser_123
chown testuser_123 /var/log/audit
