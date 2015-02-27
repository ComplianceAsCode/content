KEY_PATH="`grep -i '^tls_cacert' /etc/ldap.conf | grep -v "#" | awk '{ print $2 }'`"
if [ -d "${KEY_PATH}" ]; then
	chmod 755 "${KEY_PATH}"
	chmod 644 "${KEY_PATH}"/*
elif [ -e "${KEY_PATH}" ]; then
	chmod 644 "${KEY_PATH}"
fi
