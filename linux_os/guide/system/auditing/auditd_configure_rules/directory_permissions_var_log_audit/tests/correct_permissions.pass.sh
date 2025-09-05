#!/bin/bash
# platform = multi_platform_ubuntu
# packages = auditd

if LC_ALL=C grep -iw ^log_file /etc/audit/auditd.conf; then
  DIR=$(awk -F "=" '/^log_file/ {print $2}' /etc/audit/auditd.conf | tr -d ' ' | rev | cut -d"/" -f2- | rev)
else
  DIR="/var/log/audit"
fi

mkdir -p $DIR

chmod -R g-w,o-rwx $DIR
