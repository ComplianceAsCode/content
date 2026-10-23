#!/bin/bash
# packages = audit

if LC_ALL=C grep -iw ^log_group /etc/audit/auditd.conf; then
  sed -i 's/^log_group.*/log_group = audit/' /etc/audit/auditd.conf
else
  echo "log_group = audit" >> /etc/audit/auditd.conf
fi

touch "/var/log/audit/audit.log"
chown root -R "/var/log/audit/"
chgrp audit -R "/var/log/audit"
