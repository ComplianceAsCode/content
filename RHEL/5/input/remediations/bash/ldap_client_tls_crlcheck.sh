if [ $(cat /etc/ldap.conf | grep -c "^tls_crlcheck") = "0" ]; then
	echo "tls_crlcheck all" | tee -a /etc/ldap.conf &>/dev/null
else
	sed -i 's/^tls_crlcheck.*/tls_crlcheck all/' /etc/ldap.conf
fi
