if [ $(cat /etc/ssh/sshd_config | grep -ic "^RhostsRSAAuthentication") = "0" ]; then
	echo "RhostsRSAAuthentication no" | tee -a /etc/ssh/sshd_config &>/dev/null
else
	sed -i 's/^RhostsRSAAuthentication.*/RhostsRSAAuthentication no/' /etc/ssh/sshd_config
fi
service sshd restart 1>/dev/null