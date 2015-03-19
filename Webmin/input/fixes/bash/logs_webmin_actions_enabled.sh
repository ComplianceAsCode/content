if [ "$(grep -c '^log=' /etc/webmin/config)" = "0" ]; then
	echo "log=1" >> /etc/webmin/config
else
	sed -i "s/^log=.*/log=1/" /etc/webmin/config
fi