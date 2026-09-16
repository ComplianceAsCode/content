#!/bin/bash
# packages = zabbix-agent
# platform = multi_platform_debian
# remediation = none

mkdir -p /etc/zabbix
cat > /etc/zabbix/zabbix_agentd.conf <<EOF
Server=192.168.1.10
ServerActive=127.0.0.1
EOF
