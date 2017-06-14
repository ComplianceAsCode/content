# platform = Webmin
if [ "$(grep -c '^noremember=' /etc/webmin/config)" = "0" ]; then
	echo "noremember=1" >> /etc/webmin/config
else
	sed -i "s/^noremember=.*/noremember=1/" /etc/webmin/config
fi
