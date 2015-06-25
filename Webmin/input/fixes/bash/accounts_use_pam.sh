if [ "$(grep -c '^no_pam=' /etc/webmin/miniserv.conf)" = "0" ]; then
	echo "no_pam=0" >> /etc/webmin/miniserv.conf
else
	sed -i "s/^no_pam=.*/no_pam=0/" /etc/webmin/miniserv.conf
fi