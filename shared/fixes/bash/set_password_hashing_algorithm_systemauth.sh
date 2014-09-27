if ! grep -q "sha512" /etc/pam.d/system-auth; then   
	sed -i --follow-symlink "/^password[\s]sufficient[\s]pam_unix.so/ s/$/ sha512$/" /etc/pam.d/system-auth
fi
