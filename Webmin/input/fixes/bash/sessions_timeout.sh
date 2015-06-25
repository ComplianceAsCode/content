source ./templates/support.sh
populate var_webmin_sessions_timeout

if [ "$(grep -c '^logouttime=' /etc/webmin/miniserv.conf)" = "0" ]; then
	echo logouttime=$var_webmin_sessions_timeout >> /etc/webmin/miniserv.conf
else
	sed -i "s/^logouttime=.*/logouttime=$var_webmin_sessions_timeout/" /etc/webmin/miniserv.conf
fi