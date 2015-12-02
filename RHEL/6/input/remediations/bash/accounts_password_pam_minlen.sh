# platform = Red Hat Enterprise Linux 6
source ./templates/support.sh
populate var_password_pam_minlen

if grep -q "minlen=" /etc/pam.d/system-auth
then
	sed -i --follow-symlinks "s/\(minlen *= *\).*/\1$var_password_pam_minlen/" /etc/pam.d/system-auth
else
	sed -i --follow-symlinks "/pam_cracklib.so/ s/$/ minlen=$var_password_pam_minlen/" /etc/pam.d/system-auth
fi
