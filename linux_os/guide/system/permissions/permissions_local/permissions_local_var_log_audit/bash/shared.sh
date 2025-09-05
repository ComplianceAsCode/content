# platform = multi_platform_sle,multi_platform_slmicro

current_permissions_rules=$(grep -i audit /etc/permissions.local)
if [ ${#current_permissions_rules} -ne 0 ]
then
  echo "We will delete existing permissions"
  sed -ri '/^\/var\/log\/audit\s+root:.*/d' /etc/permissions.local
  sed -ri '/^\/var\/log\/audit\/audit.log\s+root.*/d' /etc/permissions.local 
  sed -ri '/^\/etc\/audit\/audit.rules\s+root.*/d' /etc/permissions.local
  sed -ri '/^\/etc\/audit\/rules.d\/audit.rules\s+root.*/d' /etc/permissions.local
fi
echo "There are no permission rules for audit information files and folders. We will add them"
echo "/var/log/audit root:root 600" >> /etc/permissions.local
echo "/var/log/audit/audit.log root:root 600" >> /etc/permissions.local
echo "/etc/audit/audit.rules root:root 640" >> /etc/permissions.local
echo "/etc/audit/rules.d/audit.rules root:root 640" >> /etc/permissions.local

check_stats=$(chkstat /etc/permissions.local)
if [ ${#check_stats} -gt 0 ]
then
  echo "Audit information files and folders don't have correct permissions.We will set them"
  chkstat --set /etc/permissions.local
fi
