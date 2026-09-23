#!/bin/bash
# packages = zabbix-agent
# platform = multi_platform_debian

# Both Server and ServerActive point to a real monitoring server instead of
# the packaged 127.0.0.1 default. Expected result: PASS.
mkdir -p /etc/zabbix
cat > /etc/zabbix/zabbix_agentd.conf <<EOF
Server=192.168.1.10
ServerActive=192.168.1.10
EOF
