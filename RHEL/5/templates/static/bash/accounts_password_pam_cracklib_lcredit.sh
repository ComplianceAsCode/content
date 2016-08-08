. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_cracklib_lcredit

if [ $(grep -c "lcredit=" /etc/pam.d/system-auth) != 0 ]; then
	sed -i "s/lcredit=[0-9]*/lcredit=$var_password_pam_cracklib_lcredit/" /etc/pam.d/system-auth
else
	sed -i "/password.*pam_cracklib.so/s/$/ lcredit=$var_password_pam_cracklib_lcredit/" /etc/pam.d/system-auth
fi
if [ -e /etc/pam.d/system-auth-ac ]; then
	if [ $(grep -c "lcredit=" /etc/pam.d/system-auth-ac) != 0 ]; then
		sed -i "s/lcredit=[0-9]*/lcredit=$var_password_pam_cracklib_lcredit/" /etc/pam.d/system-auth-ac
	else
		sed -i "/password.*pam_cracklib.so/s/$/ lcredit=$var_password_pam_cracklib_lcredit/" /etc/pam.d/system-auth-ac
	fi
fi
