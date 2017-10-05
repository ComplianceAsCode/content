# platform = Webmin
. /usr/share/scap-security-guide/remediation_functions
populate var_webmin_module_useradmin_accounts_max

if [ "$(grep -c '^default_max=' /etc/webmin/useradmin/config)" = "0" ]; then
	echo default_max=$var_webmin_module_useradmin_accounts_max >> /etc/webmin/useradmin/config
else
	sed -i "s/^default_max=.*/default_max=$var_webmin_module_useradmin_accounts_max/" /etc/webmin/useradmin/config
fi
