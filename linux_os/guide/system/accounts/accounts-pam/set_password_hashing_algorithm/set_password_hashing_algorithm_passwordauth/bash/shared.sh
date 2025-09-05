# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_rhv

if ! grep -q "^password.*sufficient.*pam_unix.so.*sha512" "/etc/pam.d/password-auth"; then
	sed -i --follow-symlinks "/^password.*sufficient.*pam_unix.so/ s/$/ sha512/" "/etc/pam.d/password-auth"
fi
