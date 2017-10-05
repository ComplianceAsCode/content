# platform = Webmin
if [ "$(grep -c '^passwd_mode=' /etc/webmin/miniserv.conf)" = "0" ]; then
	echo "passwd_mode=2" >> /etc/webmin/miniserv.conf
else
	sed -i "s/^passwd_mode=.*/passwd_mode=2/" /etc/webmin/miniserv.conf
fi
