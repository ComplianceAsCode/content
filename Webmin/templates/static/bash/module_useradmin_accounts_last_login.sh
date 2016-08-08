if [ "$(grep -c '^last_show=' /etc/webmin/useradmin/config)" = "0" ]; then
	echo "last_show=1" >> /etc/webmin/useradmin/config
else
	sed -i "s/^last_show=.*/last_show=1/" /etc/webmin/useradmin/config
fi