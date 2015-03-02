if [ $(cat /etc/ldap.conf | grep -c "^tls_checkpeer") = "0" ]; then
	echo "tls_checkpeer yes" | tee -a /etc/ldap.conf &>/dev/null
else
	sed -i 's/^tls_checkpeer.*/tls_checkpeer yes/' /etc/ldap.conf
fi
