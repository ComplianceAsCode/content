# platform = Webmin
if [ "$(grep -c '^passwd_cmd=' /etc/webmin/config)" = "0" ]; then
	echo "passwd_cmd=/usr/bin/passwd" >> /etc/webmin/config
else
	sed -i "s/^passwd_cmd=.*/passwd_cmd=\/usr\/bin\/passwd/" /etc/webmin/config
fi
