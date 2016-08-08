. /usr/share/scap-security-guide/remediation_functions
populate password_history_retain_number

if [ $(egrep -c "password\s*(sufficient|required)\s*(pam_unix.so|pam_pwhistory).*remember" /etc/pam.d/system-auth) != 0 ]; then
	sed -i "s/remember=[0-9]*/remember=${password_history_retain_number}/" /etc/pam.d/system-auth
else
	if [ $(egrep -c "password.*(pam_unix.so|pam_pwhistory)" /etc/pam.d/system-auth) != 0 ]; then
		sed -i "/password.*\(pam_unix.so\|pam_pwhistory.so\)/s/$/ remember=${password_history_retain_number}/" /etc/pam.d/system-auth
	else
		sed -i "/password.*pam_cracklib.so/ipassword    sufficient   pam_unix.so remember=${password_history_retain_number} sha512" /etc/pam.d/system-auth
	fi
fi
if [ -e /etc/pam.d/system-auth-ac ]; then
	if [ $(egrep -c "password\s*(sufficient|required)\s*(pam_unix.so|pam_pwhistory).*remember" /etc/pam.d/system-auth-ac) != 0 ]; then
		sed -i "s/remember=[0-9]*/remember=${password_history_retain_number}/" /etc/pam.d/system-auth-ac
	else
		sed -i "/password.*\(pam_unix.so\|pam_pwhistory.so\)/s/$/ remember=${password_history_retain_number}/" /etc/pam.d/system-auth-ac
	fi
fi
