. /usr/share/scap-security-guide/remediation_functions
populate max_concurrent_login_sessions_value

if [ $(grep -v "#" /etc/security/limits.conf | grep -c "maxlogins") = "0" ]; then
	echo "* hard maxlogins ${max_concurrent_login_sessions_value}" >>/etc/security/limits.conf
else
	sed -i 's/.*maxlogins.*/* hard maxlogins ${max_concurrent_login_sessions_value}/' /etc/security/limits.conf
fi
