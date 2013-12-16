source ./templates/support.sh
populate var_accounts_max_concurrent_login_sessions

echo "*	hard	maxlogins	$var_accounts_max_concurrent_login_sessions" >> /etc/security/limits.conf
