#!/bin/bash
# platform = multi_platform_all
# packages = audit

if LC_ALL=C grep -iw ^log_file /etc/audit/auditd.conf; then
  sed -i 's/^log_file.*/log_file = \/mnt\/logging\/audit\/audit.log/' /etc/audit/auditd.conf
else
  echo "log_file = /mnt/logging/audit/audit.log" >> /etc/audit/auditd.conf
fi

if LC_ALL=C grep -iw ^log_group /etc/audit/auditd.conf; then
  sed -i 's/^log_group.*//' /etc/audit/auditd.conf
fi

mkdir -p /mnt/logging/audit

chmod 0750 /mnt/logging/audit
