if rpm -qa | grep -q net-snmp; then
	yum -y remove net-snmp
fi
