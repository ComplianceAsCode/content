if [ "$(grep -c no_ssl3 /usr/libexec/webmin/miniserv.pl)" = "0" ]; then
	if [ "$(grep -c '^ssl_cipher_list=' /etc/webmin/miniserv.conf)" = "0" ]; then
		echo 'ssl_cipher_list=ECDHE-RSA-AES256-SHA384:AES256-SHA256:RC4:HIGH:+TLSv1.2:+TLSv1:!MD5:!SSLv2:!SSLv3:!ADH:!aNULL:!eNULL:!NULL:!DH:!EDH:!AESGCM' >> /etc/webmin/miniserv.conf
	else
		sed -i 's/^ssl_cipher_list=.*/ssl_cipher_list=ECDHE-RSA-AES256-SHA384:AES256-SHA256:RC4:HIGH:+TLSv1.2:+TLSv1:!MD5:!SSLv2:!SSLv3:!ADH:!aNULL:!eNULL:!NULL:!DH:!EDH:!AESGCM/' /etc/webmin/miniserv.conf
	fi
else
	if [ "$(grep -c '^ssl_cipher_list=' /etc/webmin/miniserv.conf)" = "0" ]; then
		echo 'ssl_cipher_list=ECDHE-RSA-AES256-SHA384:AES256-SHA256:RC4:HIGH:+TLSv1.2:+TLSv1:!MD5:!SSLv2:SSLv3:!ADH:!aNULL:!eNULL:!NULL:!DH:!EDH:!AESGCM' >> /etc/webmin/miniserv.conf
	else
		sed -i 's/^ssl_cipher_list=.*/ssl_cipher_list=ECDHE-RSA-AES256-SHA384:AES256-SHA256:RC4:HIGH:+TLSv1.2:+TLSv1:!MD5:!SSLv2:SSLv3:!ADH:!aNULL:!eNULL:!NULL:!DH:!EDH:!AESGCM/' /etc/webmin/miniserv.conf
	fi
	if [ "$(grep -c '^no_ssl2=' /etc/webmin/miniserv.conf)" = "0" ]; then
		echo 'no_ssl2=1' >> /etc/webmin/miniserv.conf
	else
		sed -i 's/^no_ssl2=.*/no_ssl2=1/' /etc/webmin/miniserv.conf
	fi
	if [ "$(grep -c '^no_ssl3=' /etc/webmin/miniserv.conf)" = "0" ]; then
		echo 'no_ssl3=1' >> /etc/webmin/miniserv.conf
	else
		sed -i 's/^no_ssl3=.*/no_ssl3=1/' /etc/webmin/miniserv.conf
	fi
fi
if [ "$(grep -c '^ssl_honorcipherorder=' /etc/webmin/miniserv.conf)" = "0" ]; then
	echo 'ssl_honorcipherorder=1' >> /etc/webmin/miniserv.conf
else
	sed -i 's/^ssl_honorcipherorder=.*/ssl_honorcipherorder=1/' /etc/webmin/miniserv.conf
fi