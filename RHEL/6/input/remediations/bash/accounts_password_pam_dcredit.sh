# platform = Red Hat Enterprise Linux 6
source ./templates/support.sh
populate var_password_pam_dcredit

if grep -q "dcredit=" /etc/pam.d/system-auth; then
	sed -i --follow-symlinks "s/\(dcredit *= *\).*/\1$var_password_pam_dcredit/" /etc/pam.d/system-auth
else
	sed -i --follow-symlinks "/pam_cracklib.so/ s/$/ dcredit=$var_password_pam_dcredit/" /etc/pam.d/system-auth
fi
