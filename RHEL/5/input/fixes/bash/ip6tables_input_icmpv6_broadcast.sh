if [ ! -e /etc/sysconfig/ip6tables ] || [ "$(grep -c ^ /etc/sysconfig/ip6tables)" -lt "5" ]; then
	echo -e "*filter\n:INPUT DROP [0:0]\n:FORWARD DROP [0:0]\n:OUTPUT ACCEPT [0:0]\nCOMMIT" | tee /etc/sysconfig/ip6tables &>/dev/null
	echo "-A INPUT -p icmpv6 -d ff02::1 --icmpv6-type 128 -j DROP" | tee -a /etc/sysconfig/ip6tables &>/dev/null 
else
	echo "-A INPUT -p icmpv6 -d ff02::1 --icmpv6-type 128 -j DROP" | tee -a /etc/sysconfig/ip6tables &>/dev/null 
fi
