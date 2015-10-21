if [ "$(egrep -c '(--icmp-type 14|timestamp-reply) -j DROP')" = "0" ]; then
	/sbin/iptables -I INPUT -p ICMP --icmp-type timestamp-reply -j DROP
fi
if [ "$(egrep -c '(--icmp-type 13|timestamp-request) -j DROP')" = "0" ]; then
	/sbin/iptables -I INPUT -p ICMP --icmp-type timestamp-request -j DROP
fi
/sbin/iptables-save > /etc/sysconfig/iptables
if [ "$(grep -c 'icmp-type 13' /etc/sysconfig/iptables)" != "0" ]; then
	sed -i 's/icmp-type 13/icmp-type timestamp-request/' /etc/sysconfig/iptables
fi
if [ "$(grep -c 'icmp-type 14' /etc/sysconfig/iptables)" != "0" ]; then
	sed -i 's/icmp-type 14/icmp-type timestamp-reply/' /etc/sysconfig/iptables
fi
