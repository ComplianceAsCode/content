# platform = multi_platform_rhel
if grep --silent ^ENCRYPT_METHOD /etc/login.defs ; then
	sed -i 's/^ENCRYPT_METHOD.*/ENCRYPT_METHOD SHA512/g' /etc/login.defs
else
	echo "" >> /etc/login.defs
	echo "ENCRYPT_METHOD SHA512" >> /etc/login.defs
fi
