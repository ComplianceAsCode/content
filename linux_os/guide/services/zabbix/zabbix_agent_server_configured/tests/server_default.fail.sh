#!/bin/bash
# packages = zabbix-agent
# platform = multi_platform_debian
# remediation = none

# Server is left at the packaged default, even though ServerActive is
# correctly configured. Expected result: FAIL.
mkdir -p /etc/zabbix
cat > /etc/zabbix/zabbix_agentd.conf <<EOF
Server=127.0.0.1
ServerActive=192.168.1.10
EOF
