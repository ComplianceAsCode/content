if [ $(grep "password.*pam_unix.so" /etc/pam.d/system-auth | egrep -c '(descrypt|bigcrypt|md5|sha256)') != 0 ]; then
	sed -i '/password.*pam_unix.so/s/\(descrypt\|bigcrypt\|md5\|sha256\)/sha512/' /etc/pam.d/system-auth
else
	sed -i '/password.*pam_unix.so/s/$/ sha512/' /etc/pam.d/system-auth
fi
if [ -e /etc/pam.d/system-auth-ac ]; then
	if [ $(grep "password.*pam_unix.so" /etc/pam.d/system-auth-ac | egrep -c '(descrypt|bigcrypt|md5|sha256)') != 0 ]; then
		sed -i '/password.*pam_unix.so/s/\(descrypt\|bigcrypt\|md5\|sha256\)/sha512/' /etc/pam.d/system-auth-ac
	else
		sed -i '/password.*pam_unix.so/s/$/ sha512/' /etc/pam.d/system-auth-ac
	fi
fi