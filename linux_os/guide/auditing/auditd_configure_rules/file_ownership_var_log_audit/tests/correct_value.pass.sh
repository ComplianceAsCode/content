#!/bin/bash
# packages = audit

if LC_ALL=C grep -iw ^log_group /etc/audit/auditd.conf; then
  sed -i '/^log_group.*$/d' /etc/audit/auditd.conf
fi

touch "/var/log/audit/audit.log"
chgrp root -R "/var/log/audit/"
chown root -R "/var/log/audit/"
