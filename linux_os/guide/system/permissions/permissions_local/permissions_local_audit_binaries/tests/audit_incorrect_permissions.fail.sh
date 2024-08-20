#!/bin/bash

# platform = multi_platform_sle,multi_platform_slmicro

for AUDIT_FILE in /usr/sbin/audispd /usr/sbin/auditctl /usr/sbin/auditd /usr/sbin/ausearch /usr/sbin/aureport /usr/sbin/autrace /usr/sbin/augenrules
do
  if [ -f $AUDIT_FILE ]
  then
     chown nobody:nobody $AUDIT_FILE
     chmod 0644 $AUDIT_FILE
  fi
done
