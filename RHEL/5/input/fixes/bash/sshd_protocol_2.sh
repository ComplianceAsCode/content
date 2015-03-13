if [ $(cat /etc/ssh/sshd_config | grep -c "^Protocol") != "0" ]; then
	sed -i 's/^Protocol.*/Protocol 2/' /etc/ssh/sshd_config
else
	echo "Protocol 2">>/etc/ssh/sshd_config
fi
service sshd restart 1>/dev/null