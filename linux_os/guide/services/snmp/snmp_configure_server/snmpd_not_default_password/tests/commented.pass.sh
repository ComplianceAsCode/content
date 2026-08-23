#!/bin/bash
# packages = net-snmp


sed -i '/.*public.*/d' /etc/snmp/snmpd.conf
sed -i '/.*private.*/d' /etc/snmp/snmpd.conf
echo '# public' >> /etc/snmp/snmpd.conf
