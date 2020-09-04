#!/bin/bash

yum -y install net-snmp

echo "something private" >> /etc/snmp/snmpd.conf
