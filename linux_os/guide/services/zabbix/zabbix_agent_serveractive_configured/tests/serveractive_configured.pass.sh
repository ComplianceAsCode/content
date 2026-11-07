#!/bin/bash
# packages = zabbix-agent
# platform = multi_platform_debian

# ServerActive points to a real monitoring server; Server is irrelevant to
# this rule and left at its packaged default. Expected result: PASS.
mkdir -p /etc/zabbix
cat > /etc/zabbix/zabbix_agentd.conf <<EOF
Server=127.0.0.1
ServerActive=192.168.1.10
EOF
