if [ "$(grep -c '^logclear=' /etc/webmin/config)" = "0" ]; then
	echo "logclear=0" >> /etc/webmin/config
else
	sed -i "s/^logclear=.*/logclear=0/" /etc/webmin/config
fi