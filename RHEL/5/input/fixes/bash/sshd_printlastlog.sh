if [ "$(grep -c '^session.*required.*pam_lastlog.so$' /etc/pam.d/sshd)" = "0" ]; then
	echo -e "session    required\tpam_lastlog.so" | tee -a /etc/pam.d/sshd &>/dev/null
elif [ "$(grep pam_lastlog /etc/pam.d/sshd | grep -c silent)" != "0" ]; then
	sed -i '/pam_lastlog/s/silent//' /etc/pam.d/sshd
fi
if [ $(cat /etc/ssh/sshd_config | grep -ic "^PrintLastLog") = "0" ]; then
	echo "PrintLastLog yes" | tee -a /etc/ssh/sshd_config &>/dev/null
else
	sed -i 's/^PrintLastLog.*/PrintLastLog yes/' /etc/ssh/sshd_config
fi
service sshd restart 1>/dev/null