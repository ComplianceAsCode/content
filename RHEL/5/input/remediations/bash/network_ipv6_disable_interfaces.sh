if [ $(grep -c "^NETWORKING_IPV6" /etc/sysconfig/network) = 0 ]; then
	echo "NETWORKING_IPV6=no" | tee -a /etc/sysconfig/network &>/dev/null
else
	sed -i 's/NETWORKING_IPV6.*/NETWORKING_IPV6=no/' /etc/sysconfig/network
fi
chkconfig ip6tables off
