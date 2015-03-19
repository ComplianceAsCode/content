if [ "$(grep -c '^passwd_same=' /etc/webmin/useradmin/config)" = "0" ]; then
	echo "passwd_same=1" >> /etc/webmin/useradmin/config
else
	sed -i "s/^passwd_same=.*/passwd_same=1/" /etc/webmin/useradmin/config
fi