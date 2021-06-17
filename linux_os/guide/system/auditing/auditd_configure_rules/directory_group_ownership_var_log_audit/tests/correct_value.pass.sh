#!/bin/bash

sed -i "/\s*log_group.*/d" /etc/audit/auditd.conf
echo "log_group = root" >> /etc/audit/auditd.conf
chgrp root /var/log/audit
