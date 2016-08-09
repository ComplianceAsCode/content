. /usr/share/scap-security-guide/remediation_functions
populate var_webmin_module_useradmin_accounts_min_length

if [ "$(grep -c '^passwd_min=' /etc/webmin/useradmin/config)" = "0" ]; then
	echo passwd_min=$var_webmin_module_useradmin_accounts_min_length >> /etc/webmin/useradmin/config
else
	sed -i "s/^passwd_min=.*/passwd_min=$var_webmin_module_useradmin_accounts_min_length/" /etc/webmin/useradmin/config
fi
