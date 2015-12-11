. /usr/share/scap-security-guide/remediation_functions
populate var_account_disable_post_pw_expiration

if [ $(cat /etc/default/useradd | grep -c "^INACTIVE=") != 0 ]; then
	sed -i "s/^INACTIVE=.*/INACTIVE=${var_account_disable_post_pw_expiration}/" /etc/default/useradd
else
	echo INACTIVE=${var_account_disable_post_pw_expiration} >>/etc/default/useradd
fi
