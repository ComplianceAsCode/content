if ! grep -q "^password.*sufficient.*pam_unix.so.*sha512" /etc/pam.d/system-auth; then   
	sed -i --follow-symlink "/^password.*sufficient.*pam_unix.so/ s/$/ sha512/" /etc/pam.d/system-auth
fi
