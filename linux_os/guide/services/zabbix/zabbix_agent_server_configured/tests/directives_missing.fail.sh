#!/bin/bash
# packages = zabbix-agent
# platform = multi_platform_debian
# remediation = none

# Neither Server nor ServerActive is present in the config file at all.
# Expected result: FAIL.
mkdir -p /etc/zabbix
echo "# no Server/ServerActive directives" > /etc/zabbix/zabbix_agentd.conf
