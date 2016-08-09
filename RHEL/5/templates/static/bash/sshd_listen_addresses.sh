MANAGEMENT_IP=$(/sbin/ifconfig | grep inet | grep -v 127.0.0.1 | cut -d: -f2 | awk '{ print $1}' | head -1)
if [ $(cat /etc/ssh/sshd_config | grep -ic "^ListenAddress") = "0" ]; then
	echo "ListenAddress ${MANAGEMENT_IP}" | tee -a /etc/ssh/sshd_config &>/dev/null
else
	sed -i "s/^ListenAddress.*/ListenAddress ${MANAGEMENT_IP}/" /etc/ssh/sshd_config
fi
service sshd restart 1>/dev/null