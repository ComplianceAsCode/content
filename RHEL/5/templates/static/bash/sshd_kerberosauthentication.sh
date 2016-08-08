if [ $(cat /etc/ssh/sshd_config | grep -ic "^KerberosAuthentication") = "0" ]; then
	echo "KerberosAuthentication no" | tee -a /etc/ssh/sshd_config &>/dev/null
else
	sed -i 's/^KerberosAuthentication.*/KerberosAuthentication no/' /etc/ssh/sshd_config
fi
service sshd restart 1>/dev/null