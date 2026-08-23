#!/bin/bash

# platform = multi_platform_sle,multi_platform_slmicro

for AUDIT_FILE in /var/log/audit /var/log/audit/audit.log /etc/audit/audit.rules /etc/audit/rules.d/audit.rules
do
  if [ -f $AUDIT_FILE ]
  then
     chown nobody:nobody $AUDIT_FILE
     chmod 0644 $AUDIT_FILE
  fi
done
