#!/bin/bash

yum -y install net-snmp

echo "something public" >> /etc/snmp/snmpd.conf

