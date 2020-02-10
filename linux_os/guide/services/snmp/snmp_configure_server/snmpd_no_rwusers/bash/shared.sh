# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora

if grep -s "rwuser" /etc/snmp/snmpd.conf | grep -qv "^#"; then
	sed -i "/^\s*#/b;/rwuser/ s/^/#/" /etc/snmp/snmpd.conf
fi
