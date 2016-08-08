if [ "$(grep -c '^ssl=' /etc/webmin/miniserv.conf)" = "0" ]; then
	echo "ssl=1" >> /etc/webmin/miniserv.conf
else
	sed -i "s/^ssl=.*/ssl=1/" /etc/webmin/miniserv.conf
fi
if [ "$(grep -c '^ssl_redirect=' /etc/webmin/miniserv.conf)" = "0" ]; then
	echo "ssl_redirect=1" >> /etc/webmin/miniserv.conf
else
	sed -i "s/^ssl_redirect=.*/ssl_redirect=1/" /etc/webmin/miniserv.conf
fi