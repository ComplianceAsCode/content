if [ $(cat /etc/ssh/sshd_config | grep -c "^StrictModes") = "0" ]; then
	echo "StrictModes yes" | tee -a /etc/ssh/sshd_config &>/dev/null
else
	sed -i 's/^StrictModes.*/StrictModes yes/' /etc/ssh/sshd_config
fi
service sshd restart 1>/dev/null