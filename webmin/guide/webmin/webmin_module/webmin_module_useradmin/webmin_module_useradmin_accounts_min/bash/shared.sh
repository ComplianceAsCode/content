# platform =  Webmin

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions
populate var_webmin_module_useradmin_accounts_min

WEBMIN_CONFIG_FILE="/etc/webmin/useradmin/config"
grep -q ^default_min $WEBMIN_CONFIG_FILE && \
  sed -i "s/default_min.*/default_min=$var_webmin_module_useradmin_accounts_min/g" $WEBMIN_CONFIG_FILE
if ! [ $? -eq 0 ]; then
    echo "default_min=$var_webmin_module_useradmin_accounts_min" >> $WEBMIN_CONFIG_FILE
fi
