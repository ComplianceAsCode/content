# platform = multi_platform_wrlinux,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_ol

if grep -s "public\|private" /etc/snmp/snmpd.conf | grep -qv "^#"; then
	sed -i "/^\s*#/b;/public\|private/ s/^/#/" /etc/snmp/snmpd.conf
fi
