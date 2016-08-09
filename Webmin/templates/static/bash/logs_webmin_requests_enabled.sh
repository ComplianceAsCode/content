if [ "$(grep -c '^log=' /etc/webmin/miniserv.conf)" = "0" ]; then
	echo "log=1" >> /etc/webmin/miniserv.conf
else
	sed -i "s/^log=.*/log=1/" /etc/webmin/miniserv.conf
fi