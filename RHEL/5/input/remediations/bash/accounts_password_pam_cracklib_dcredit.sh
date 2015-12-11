. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_cracklib_dcredit

if [ $(grep -c "dcredit=" /etc/pam.d/system-auth) != 0 ]; then
	sed -i "s/dcredit=[0-9]*/dcredit=$var_password_pam_cracklib_dcredit/" /etc/pam.d/system-auth
else
	sed -i "/password.*pam_cracklib.so/s/$/ dcredit=$var_password_pam_cracklib_dcredit/" /etc/pam.d/system-auth
fi
if [ -e /etc/pam.d/system-auth-ac ]; then
	if [ $(grep -c "dcredit=" /etc/pam.d/system-auth-ac) != 0 ]; then
		sed -i "s/dcredit=[0-9]*/dcredit=$var_password_pam_cracklib_dcredit/" /etc/pam.d/system-auth-ac
	else
		sed -i "/password.*pam_cracklib.so/s/$/ dcredit=$var_password_pam_cracklib_dcredit/" /etc/pam.d/system-auth-ac
	fi
fi
