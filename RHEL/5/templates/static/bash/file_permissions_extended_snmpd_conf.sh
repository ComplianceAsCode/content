# platform = Red Hat Enterprise Linux 5
find / -name snmpd.conf 2>/dev/null | xargs setfacl --remove-all