# platform =  Webmin

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions
populate var_webmin_module_useradmin_accounts_min_length

WEBMIN_CONFIG_FILE="/etc/webmin/useradmin/config"
grep -q ^passwd_min $WEBMIN_CONFIG_FILE && \
  sed -i "s/passwd_min.*/passwd_min=$var_webmin_module_useradmin_accounts_min_length/g" $WEBMIN_CONFIG_FILE
if ! [ $? -eq 0 ]; then
    echo "passwd_min=$var_webmin_module_useradmin_accounts_min_length" >> $WEBMIN_CONFIG_FILE
fi
