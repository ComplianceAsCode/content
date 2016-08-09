. /usr/share/scap-security-guide/remediation_functions
populate var_webmin_module_useradmin_accounts_warn

if [ "$(grep -c '^default_warn=' /etc/webmin/useradmin/config)" = "0" ]; then
	echo default_warn=$var_webmin_module_useradmin_accounts_warn >> /etc/webmin/useradmin/config
else
	sed -i "s/^default_warn=.*/default_warn=$var_webmin_module_useradmin_accounts_warn/" /etc/webmin/useradmin/config
fi
