if [ "$(grep -c '^logclear=' /etc/webmin/miniserv.conf)" = "0" ]; then
	echo "logclear=0" >> /etc/webmin/miniserv.conf
else
	sed -i "s/^logclear=.*/logclear=0/" /etc/webmin/miniserv.conf
fi