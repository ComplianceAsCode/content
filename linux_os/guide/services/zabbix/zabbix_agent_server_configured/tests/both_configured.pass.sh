#!/bin/bash
# packages = zabbix-agent
# platform = multi_platform_debian

mkdir -p /etc/zabbix
cat > /etc/zabbix/zabbix_agentd.conf <<EOF
Server=192.168.1.10
ServerActive=192.168.1.10
EOF
