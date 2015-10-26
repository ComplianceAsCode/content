if [ "$(grep -c '^logperms=' /etc/webmin/config)" = "0" ]; then
	echo "logperms=640" >> /etc/webmin/config
else
	sed -i "s/^logperms=.*/logperms=640/" /etc/webmin/config
fi