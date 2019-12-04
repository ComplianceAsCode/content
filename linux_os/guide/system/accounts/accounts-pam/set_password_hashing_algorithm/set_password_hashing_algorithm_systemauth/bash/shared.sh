# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_rhv,multi_platform_sle,multi_platform_wrlinux

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"

for pamFile in "${AUTH_FILES[@]}"
do
	if ! grep -q "^password.*sufficient.*pam_unix.so.*sha512" $pamFile; then
		sed -i --follow-symlinks "/^password.*sufficient.*pam_unix.so/ s/$/ sha512/" $pamFile
	fi
done
