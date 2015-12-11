. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_cracklib_difok

if [ $(grep -c "difok=" /etc/pam.d/system-auth) != 0 ]; then
	sed -i "s/difok=[0-9]*/difok=$var_password_pam_cracklib_difok/" /etc/pam.d/system-auth
else
	sed -i "/password.*pam_cracklib.so/s/$/ difok=$var_password_pam_cracklib_difok/" /etc/pam.d/system-auth
fi
if [ -e /etc/pam.d/system-auth-ac ]; then
	if [ $(grep -c "difok=" /etc/pam.d/system-auth-ac) != 0 ]; then
		sed -i "s/difok=[0-9]*/difok=$var_password_pam_cracklib_difok/" /etc/pam.d/system-auth-ac
	else
		sed -i "/password.*pam_cracklib.so/s/$/ difok=$var_password_pam_cracklib_difok/" /etc/pam.d/system-auth-ac
	fi
fi
