# platform = Webmin
. /usr/share/scap-security-guide/remediation_functions
populate var_webmin_module_useradmin_accounts_inactive

if [ "$(grep -c '^default_inactive=' /etc/webmin/useradmin/config)" = "0" ]; then
	echo default_inactive=$var_webmin_module_useradmin_accounts_inactive >> /etc/webmin/useradmin/config
else
	sed -i "s/^default_inactive=.*/default_inactive=$var_webmin_module_useradmin_accounts_inactive/" /etc/webmin/useradmin/config
fi
