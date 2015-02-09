source ./templates/support.sh
populate var_password_pam_minlen

if egrep -q ^minlen[[:space:]]*=[[:space:]]*[-]?[[:digit:]]+ /etc/security/pwquality.conf; then
	sed -i "s/^\(minlen *= *\).*/\1$var_password_pam_minlen/" /etc/security/pwquality.conf
else
	sed -i "/\(minlen *= *\).*/a minlen = $var_password_pam_minlen" /etc/security/pwquality.conf
fi
