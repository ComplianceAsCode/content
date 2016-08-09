. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_cracklib_ucredit

if [ $(grep -c "ucredit=" /etc/pam.d/system-auth) != 0 ]; then
	sed -i "s/ucredit=[0-9]*/ucredit=$var_password_pam_cracklib_ucredit/" /etc/pam.d/system-auth
else
	sed -i "/password.*pam_cracklib.so/s/$/ ucredit=$var_password_pam_cracklib_ucredit/" /etc/pam.d/system-auth
fi
if [ -e /etc/pam.d/system-auth-ac ]; then
	if [ $(grep -c "ucredit=" /etc/pam.d/system-auth-ac) != 0 ]; then
		sed -i "s/ucredit=[0-9]*/ucredit=$var_password_pam_cracklib_ucredit/" /etc/pam.d/system-auth-ac
	else
		sed -i "/password.*pam_cracklib.so/s/$/ ucredit=$var_password_pam_cracklib_ucredit/" /etc/pam.d/system-auth-ac
	fi
fi
