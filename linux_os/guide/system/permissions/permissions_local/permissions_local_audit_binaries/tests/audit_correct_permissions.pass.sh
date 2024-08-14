#!/bin/bash

# platform = multi_platform_sle,multi_platform_slmicro

current_permissions_rules=$(grep "^/usr/sbin/au" /etc/permissions.local)
if [ ${#current_permissions_rules} -eq 0 ]
then
  echo "There are no permission rules for audit information files and folders. We will add them"
  echo "/usr/sbin/audispd root:root 0750" >> /etc/permissions.local
  echo "/usr/sbin/auditctl root:root 0750" >> /etc/permissions.local
  echo "/usr/sbin/auditd root:root 0750" >> /etc/permissions.local
  echo "/usr/sbin/ausearch root:root 0755" >> /etc/permissions.local
  echo "/usr/sbin/aureport root:root 0755" >> /etc/permissions.local
  echo "/usr/sbin/autrace root:root 0750" >> /etc/permissions.local
  echo "/usr/sbin/augenrules root:root 0750" >> /etc/permissions.local
fi

check_stats=$(chkstat /etc/permissions.local)
if [ ${#check_stats} -gt 0 ]
then
  echo "Audit information files and folders don't have correct permissions.We will set them"
  chkstat --set /etc/permissions.local
fi
