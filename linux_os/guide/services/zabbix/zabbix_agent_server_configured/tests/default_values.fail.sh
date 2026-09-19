#!/bin/bash
# packages = zabbix-agent
# platform = multi_platform_debian
# remediation = none

# Both directives are left at the packaged default of 127.0.0.1, so the
# agent isn't actually reporting to any server. Expected result: FAIL.
mkdir -p /etc/zabbix
cat > /etc/zabbix/zabbix_agentd.conf <<EOF
Server=127.0.0.1
ServerActive=127.0.0.1
EOF
