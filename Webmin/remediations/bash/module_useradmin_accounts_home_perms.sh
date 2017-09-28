# platform = Webmin
if [ "$(grep -c '^homedir_perms=' /etc/webmin/useradmin/config)" = "0" ]; then
	echo "homedir_perms=0750" >> /etc/webmin/useradmin/config
else
	sed -i "s/^homedir_perms=.*/homedir_perms=0750/" /etc/webmin/useradmin/config
fi
