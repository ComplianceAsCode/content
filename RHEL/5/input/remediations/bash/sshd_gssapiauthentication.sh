if [ $(cat /etc/ssh/sshd_config | grep -c "^GSSAPIAuthentication") = "0" ]; then
	echo "GSSAPIAuthentication no" | tee -a /etc/ssh/sshd_config &>/dev/null
else
	sed -i 's/^GSSAPIAuthentication.*/GSSAPIAuthentication no/' /etc/ssh/sshd_config
fi
service sshd restart 1>/dev/null