# platform = multi_platform_sle,multi_platform_slmicro

CORRECT_PERMISSIONS="/var/log/messages root:root 640"
err_cnt=0
message_permissions=$(grep -i messages /etc/permissions.local)
if [ ${#message_permissions} -eq 0 ]
then
  echo "There are no permission rules for system errors messages. We will add them" 
  echo $CORRECT_PERMISSIONS >> /etc/permissions.local
  err_cnt=$((err_cnt+1))
fi

check_message_permissions=$(stat -c "%n %U:%G %a" /var/log/messages)
if [ "$check_message_permissions" != "$CORRECT_PERMISSIONS" ]
then
  echo "The permissions are not correct"
  err_cnt=$((err_cnt+1))
fi

if [ ${#err_cnt} -gt 0 ] 
then
  echo "Set the permissions"
  chkstat --set /etc/permissions.local
fi
