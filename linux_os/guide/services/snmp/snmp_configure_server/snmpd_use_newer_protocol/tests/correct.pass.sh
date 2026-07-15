#!/bin/bash
# packages = net-snmp


sed -i '/.*com2sec.*/d' /etc/snmp/snmpd.conf
sed -i '/.*rocommunity.*/d' /etc/snmp/snmpd.conf
sed -i '/.*rwcommunity.*/d' /etc/snmp/snmpd.conf
