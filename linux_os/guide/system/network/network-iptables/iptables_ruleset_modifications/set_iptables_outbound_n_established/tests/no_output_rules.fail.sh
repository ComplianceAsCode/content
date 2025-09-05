#!/bin/bash
# platform = multi_platform_all
# remediation = none

TABLES_CMDS=("iptables")
IPV6_DISABLED=$(sysctl -n net.ipv6.conf.all.disable_ipv6)

if [ "$IPV6_DISABLED" == "0" ]; then
    TABLES_CMDS+=("ip6tables")
fi

for CMD in "${TABLES_CMDS[@]}"; do
    $CMD -F OUTPUT
done
