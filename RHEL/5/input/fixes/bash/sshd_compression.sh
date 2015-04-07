if [ $(cat /etc/ssh/sshd_config | grep -ic "^Compression") = "0" ]; then
	echo "Compression delayed" | tee -a /etc/ssh/sshd_config &>/dev/null
else
	sed -i 's/^Compression.*/Compression delayed/' /etc/ssh/sshd_config
fi
service sshd restart 1>/dev/null