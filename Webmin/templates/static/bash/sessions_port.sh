# platform = Webmin
. /usr/share/scap-security-guide/remediation_functions
populate var_webmin_sessions_port

if [ "$(grep -c '^port=' /etc/webmin/miniserv.conf)" = "0" ]; then
	echo port=$var_webmin_sessions_port >> /etc/webmin/miniserv.conf
else
	sed -i "s/^port=.*/port=$var_webmin_sessions_port/" /etc/webmin/miniserv.conf
fi
if [ "$(grep -c '^listen=' /etc/webmin/miniserv.conf)" = "0" ]; then
	echo listen=$var_webmin_sessions_port >> /etc/webmin/miniserv.conf
else
	sed -i "s/^listen=.*/listen=$var_webmin_sessions_port/" /etc/webmin/miniserv.conf
fi
