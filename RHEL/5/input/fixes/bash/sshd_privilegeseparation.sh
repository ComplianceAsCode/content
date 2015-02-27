if [ $(cat /etc/ssh/sshd_config | grep -ic "^UsePrivilegeSeparation") = "0" ]; then
	echo "UsePrivilegeSeparation yes" | tee -a /etc/ssh/sshd_config &>/dev/null
else
	sed -i 's/^UsePrivilegeSeparation.*/UsePrivilegeSeparation yes/' /etc/ssh/sshd_config
fi
service sshd restart 1>/dev/null