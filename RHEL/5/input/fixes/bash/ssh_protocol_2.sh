if [ $(cat /etc/ssh/ssh_config | grep -c "^Protocol") != "0" ]; then
	sed -i 's/^Protocol.*/Protocol 2/' /etc/ssh/ssh_config
else
	echo "Protocol 2">>/etc/ssh/ssh_config
fi

