# platform =  Webmin

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions
populate var_webmin_module_useradmin_accounts_max

WEBMIN_CONFIG_FILE="/etc/webmin/useradmin/config"
grep -q ^default_max $WEBMIN_CONFIG_FILE && \
  sed -i "s/default_max.*/default_max=$var_webmin_module_useradmin_accounts_max/g" $WEBMIN_CONFIG_FILE
if ! [ $? -eq 0 ]; then
    echo "default_max=$var_webmin_module_useradmin_accounts_max" >> $WEBMIN_CONFIG_FILE
fi
