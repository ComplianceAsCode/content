if [ "$(cat /etc/ldap.conf | grep -c '^ssl ')" = "0" ]; then
	echo "ssl start_tls" | tee -a /etc/ldap.conf &>/dev/null
else
	sed -i 's/^ssl .*/ssl start_tls/' /etc/ldap.conf
fi
if [ "$(cat /etc/ldap.conf | grep -c '^tls_ciphers ')" = "0" ]; then
	echo "tls_ciphers TLSv1" | tee -a /etc/ldap.conf &>/dev/null
else
	sed -i 's/^tls_ciphers .*/tls_ciphers TLSv1/' /etc/ldap.conf
fi
