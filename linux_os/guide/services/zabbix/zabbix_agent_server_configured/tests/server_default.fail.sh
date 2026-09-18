#!/bin/bash
# packages = zabbix-agent
# platform = multi_platform_debian
# remediation = none

# ServerActive is configured, but Server is still left at the packaged
# 127.0.0.1 default. Expected result: FAIL.
mkdir -p /etc/zabbix
cat > /etc/zabbix/zabbix_agentd.conf <<EOF
Server=127.0.0.1
ServerActive=192.168.1.10
EOF
