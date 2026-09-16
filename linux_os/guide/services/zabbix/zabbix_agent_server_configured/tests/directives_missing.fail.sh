#!/bin/bash
# packages = zabbix-agent
# platform = multi_platform_debian
# remediation = none

mkdir -p /etc/zabbix
echo "# no Server/ServerActive directives" > /etc/zabbix/zabbix_agentd.conf
