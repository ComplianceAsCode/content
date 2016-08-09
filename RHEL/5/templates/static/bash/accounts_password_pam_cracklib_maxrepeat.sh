. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_cracklib_maxrepeat

if [ $(grep -c "maxrepeat=" /etc/pam.d/system-auth) != 0 ]; then
	sed -i "s/maxrepeat=[0-9]*/maxrepeat=$var_password_pam_cracklib_maxrepeat/" /etc/pam.d/system-auth
else
	sed -i "/password.*pam_cracklib.so/s/$/ maxrepeat=$var_password_pam_cracklib_maxrepeat/" /etc/pam.d/system-auth
fi
if [ -e /etc/pam.d/system-auth-ac ]; then
	if [ $(grep -c "maxrepeat=" /etc/pam.d/system-auth-ac) != 0 ]; then
		sed -i "s/maxrepeat=[0-9]*/maxrepeat=$var_password_pam_cracklib_maxrepeat/" /etc/pam.d/system-auth-ac
	else
		sed -i "/password.*pam_cracklib.so/s/$/ maxrepeat=$var_password_pam_cracklib_maxrepeat/" /etc/pam.d/system-auth-ac
	fi
fi