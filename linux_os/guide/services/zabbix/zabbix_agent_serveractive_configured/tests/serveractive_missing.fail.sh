#!/bin/bash
# packages = zabbix-agent
# platform = multi_platform_debian
# remediation = none

# ServerActive directive is not present in the config file at all.
# Expected result: FAIL.
mkdir -p /etc/zabbix
echo "# no ServerActive directive" > /etc/zabbix/zabbix_agentd.conf
