# platform = multi_platform_rhel,multi_platform_fedora,multi_platorm_ol,multi_platform_rhv

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions


if grep -q "maxrepeat=" /etc/pam.d/system-auth; then   
	sed -i --follow-symlink "s/\(maxrepeat *= *\).*/\13/" /etc/pam.d/system-auth
else
	sed -i --follow-symlink "/pam_cracklib.so/ s/$/ maxrepeat=3/" /etc/pam.d/system-auth
fi


if grep -q "maxrepeat=" /etc/pam.d/password-auth; then   
	sed -i --follow-symlink "s/\(maxrepeat *= *\).*/\13/" /etc/pam.d/password-auth
else
	sed -i --follow-symlink "/pam_cracklib.so/ s/$/ maxrepeat=3/" /etc/pam.d/password-auth
fi