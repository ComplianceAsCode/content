# platform = multi_platform_rhel,multi_platform_fedora,multi_platorm_ol,multi_platform_rhv

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

if grep -q "ucredit=" /etc/pam.d/system-auth; then
	sed -i --follow-symlink "s/\(ucredit *= *\).*/\1-1/" /etc/pam.d/system-auth
else
	sed -i --follow-symlink "/pam_cracklib.so/ s/$/ ucredit=-1/" /etc/pam.d/system-auth
fi

if grep -q "ucredit=" /etc/pam.d/password-auth; then
	sed -i --follow-symlink "s/\(ucredit *= *\).*/\1-1/" /etc/pam.d/password-auth
else
	sed -i --follow-symlink "/pam_cracklib.so/ s/$/ ucredit=-1/" /etc/pam.d/password-auth
fi