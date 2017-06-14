# platform = Red Hat Enterprise Linux 5
if [ $(cat /etc/ssh/ssh_config | grep -c "^GSSAPIAuthentication") = "0" ]; then
	echo "GSSAPIAuthentication no" | tee -a /etc/ssh/ssh_config &>/dev/null
else
	sed -i 's/^GSSAPIAuthentication.*/GSSAPIAuthentication no/' /etc/ssh/ssh_config
fi
