# platform =  Webmin

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions
populate var_webmin_module_useradmin_accounts_password_hash

WEBMIN_CONFIG_FILE="/etc/webmin/useradmin/config"
grep -q ^md5 $WEBMIN_CONFIG_FILE && \
  sed -i "s/^md5.*/md5=$var_webmin_module_useradmin_accounts_password_hash/g" $WEBMIN_CONFIG_FILE
if ! [ $? -eq 0 ]; then
    echo "md5=$var_webmin_module_useradmin_accounts_password_hash" >> $WEBMIN_CONFIG_FILE
fi
