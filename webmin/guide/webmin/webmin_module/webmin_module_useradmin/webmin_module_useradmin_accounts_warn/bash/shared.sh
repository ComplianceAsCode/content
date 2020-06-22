# platform =  Webmin

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions
populate var_webmin_module_useradmin_accounts_warn

WEBMIN_CONFIG_FILE="/etc/webmin/useradmin/config"
grep -q ^default_warn $WEBMIN_CONFIG_FILE && \
  sed -i "s/^default_warn.*/default_warn=$var_webmin_module_useradmin_accounts_warn/g" $WEBMIN_CONFIG_FILE
if ! [ $? -eq 0 ]; then
    echo "default_warn=$var_webmin_module_useradmin_accounts_warn" >> $WEBMIN_CONFIG_FILE
fi
