# platform =  Webmin

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions
populate var_webmin_sessions_timeout

WEBMIN_CONFIG_FILE="/etc/webmin/miniserv.conf"
grep -q ^logouttime $WEBMIN_CONFIG_FILE && \
  sed -i "s/^logouttime.*/logouttime=$var_webmin_sessions_timeout/g" $WEBMIN_CONFIG_FILE
if ! [ $? -eq 0 ]; then
    echo "logouttime=$var_webmin_sessions_timeout" >> $WEBMIN_CONFIG_FILE
fi
