. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_cracklib_minlen

if [ $(grep -c "minlen=" /etc/pam.d/system-auth) != 0 ]; then
	sed -i "s/minlen=[0-9]*/minlen=$var_password_pam_cracklib_minlen/" /etc/pam.d/system-auth
else
	sed -i "/password.*pam_cracklib.so/s/$/ minlen=$var_password_pam_cracklib_minlen/" /etc/pam.d/system-auth
fi
if [ -e /etc/pam.d/system-auth-ac ]; then
	if [ $(grep -c "minlen=" /etc/pam.d/system-auth-ac) != 0 ]; then
		sed -i "s/minlen=[0-9]*/minlen=$var_password_pam_cracklib_minlen/" /etc/pam.d/system-auth-ac
	else
		sed -i "/password.*pam_cracklib.so/s/$/ minlen=$var_password_pam_cracklib_minlen/" /etc/pam.d/system-auth-ac
	fi
fi
