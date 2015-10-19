if [ "$(grep -c '^passwd_dict=' /etc/webmin/useradmin/config)" = "0" ]; then
	echo "passwd_dict=1" >> /etc/webmin/useradmin/config
else
	sed -i "s/^passwd_dict=.*/passwd_dict=1/" /etc/webmin/useradmin/config
fi