# platform =  Webmin

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions
populate var_webmin_sessions_port

WEBMIN_CONFIG_FILE="/etc/webmin/miniserv.conf"
grep -q ^port $WEBMIN_CONFIG_FILE && \
  sed -i "s/^port.*/port=$var_webmin_sessions_port/g" $WEBMIN_CONFIG_FILE
if ! [ $? -eq 0 ]; then
    echo "port=$var_webmin_sessions_port" >> $WEBMIN_CONFIG_FILE
fi
grep -q ^listen $WEBMIN_CONFIG_FILE && \
  sed -i "s/^listen.*/listen=$var_webmin_sessions_port/g" $WEBMIN_CONFIG_FILE
if ! [ $? -eq 0 ]; then
    echo "listen=$var_webmin_sessions_port" >> $WEBMIN_CONFIG_FILE
fi
