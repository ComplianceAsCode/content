#!/bin/bash
# packages = audit

if LC_ALL=C grep -iw ^log_group /etc/audit/auditd.conf; then
  sed -i 's/^log_group.*/log_group = audit/' /etc/audit/auditd.conf
else
  echo "log_group = audit" >> /etc/audit/auditd.conf
fi

groupadd testgroup

mkdir -p "/var/log/audit"
chgrp testgroup "/var/log/audit"
