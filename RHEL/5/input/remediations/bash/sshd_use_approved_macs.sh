if [ $(cat /etc/ssh/sshd_config | grep -c "^MACs") = "0" ]; then
	echo "MACs hmac-sha1" | tee -a /etc/ssh/sshd_config &>/dev/null
else
	sed -i 's/^MACs.*/MACs hmac-sha1/' /etc/ssh/sshd_config
fi
service sshd restart 1>/dev/null