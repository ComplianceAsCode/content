# platform = Red Hat Enterprise Linux 7

if grep -s "public\|private" /etc/snmp/snmpd.conf | grep -qv "^#"; then
	sed -i "/^\s*#/b;/public\|private/ s/^/#/" /etc/snmp/snmpd.conf
fi
