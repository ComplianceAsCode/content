if [ "$(grep -c '#.*auth.*required.*pam_wheel.so' /etc/pam.d/su)" != "0" ]; then
	sed -i '/auth.*required.*pam_wheel.so/s/#//g' /etc/pam.d/su
else
	sed -i '/auth.*include/iauth\t\trequired\tpam_wheel.so use_uid' /etc/pam.d/su
fi
