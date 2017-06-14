# platform = Webmin
if [ "$(grep -c '^passwd_stars=' /etc/webmin/useradmin/config)" = "0" ]; then
	echo "passwd_stars=1" >> /etc/webmin/useradmin/config
else
	sed -i "s/^passwd_stars=.*/passwd_stars=1/" /etc/webmin/useradmin/config
fi
