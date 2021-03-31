#!/bin/bash
# packages = net-snmp

systemctl stop snmpd
systemctl disable snmpd
systemctl mask snmpd
