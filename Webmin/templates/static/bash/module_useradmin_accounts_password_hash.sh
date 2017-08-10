# platform = Webmin
. /usr/share/scap-security-guide/remediation_functions
populate var_webmin_module_useradmin_accounts_password_hash

if [ "$(grep -c '^md5=' /etc/webmin/useradmin/config)" = "0" ]; then
	echo md5=$var_webmin_module_useradmin_accounts_password_hash >> /etc/webmin/useradmin/config
else
	sed -i "s/^md5=.*/md5=$var_webmin_module_useradmin_accounts_password_hash/" /etc/webmin/useradmin/config
fi
