find / -xdev -name snmpd.conf 2>/dev/null | xargs sed -i '/.*\(v1\|v2c\|community\|com2sec\).*/s/^/#/'
