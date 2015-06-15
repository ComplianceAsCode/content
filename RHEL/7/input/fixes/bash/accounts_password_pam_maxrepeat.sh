source ./templates/support.sh
populate var_password_pam_maxrepeat

if egrep -q ^maxrepeat[[:space:]]*=[[:space:]]*[[:digit:]]+ /etc/security/pwquality.conf; then
	sed -i "s/^\(maxrepeat *= *\).*/\1$var_password_pam_maxrepeat/" /etc/security/pwquality.conf
else
	sed -i "/\(maxrepeat *= *\).*/a maxrepeat = $var_password_pam_maxrepeat" /etc/security/pwquality.conf
fi
