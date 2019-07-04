# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv
if grep --silent ^ENCRYPT_METHOD /etc/login.defs ; then
	sed -i 's/^ENCRYPT_METHOD.*/ENCRYPT_METHOD SHA512/g' /etc/login.defs
else
	echo "" >> /etc/login.defs
	echo "ENCRYPT_METHOD SHA512" >> /etc/login.defs
fi
