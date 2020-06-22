# platform =  Webmin

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions
populate var_webmin_module_useradmin_accounts_inactive

WEBMIN_CONFIG_FILE="/etc/webmin/useradmin/config"
grep -q ^default_inactive $WEBMIN_CONFIG_FILE && \
  sed -i "s/default_inactive.*/default_inactive=$var_webmin_module_useradmin_accounts_inactive/g" $WEBMIN_CONFIG_FILE
if ! [ $? -eq 0 ]; then
    echo "default_inactive=$var_webmin_module_useradmin_accounts_inactive" >> $WEBMIN_CONFIG_FILE
fi
