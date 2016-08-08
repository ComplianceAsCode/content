if [ "$(grep -c '^logperms=' /etc/webmin/miniserv.conf)" = "0" ]; then
	echo "logperms=640" >> /etc/webmin/miniserv.conf
else
	sed -i "s/^logperms=.*/logperms=640/" /etc/webmin/miniserv.conf
fi