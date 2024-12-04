# platform = multi_platform_all
# variables = sshd_max_auth_tries_value=4
SSHD_CONFIG="/etc/ssh/sshd_config"

if grep -q "^MaxAuthTries" $SSHD_CONFIG; then
	sed -i "s/^MaxAuthTries.*/MaxAuthTries 1000/" $SSHD_CONFIG
else
	echo "MaxAuthTries 1000" >> $SSHD_CONFIG
fi
