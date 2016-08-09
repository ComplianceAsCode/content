if [ "$(grep -c '^passwd_re=' /etc/webmin/useradmin/config)" = "0" ]; then
	echo "passwd_re=^.*(?=.*[a-z])(?=.*[A-Z])(?=.*[\d])(?=.*[\W]).*$" >> /etc/webmin/useradmin/config
else
	sed -i "s/^passwd_re=.*/passwd_re=^.*(?=.*[a-z])(?=.*[A-Z])(?=.*[\\\\d])(?=.*[\\\\W]).*$/" /etc/webmin/useradmin/config
fi