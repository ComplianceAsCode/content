# platform = Webmin
. /usr/share/scap-security-guide/remediation_functions
populate var_webmin_module_useradmin_accounts_min

if [ "$(grep -c '^default_min=' /etc/webmin/useradmin/config)" = "0" ]; then
	echo default_min=$var_webmin_module_useradmin_accounts_min >> /etc/webmin/useradmin/config
else
	sed -i "s/^default_min=.*/default_min=$var_webmin_module_useradmin_accounts_min/" /etc/webmin/useradmin/config
fi
