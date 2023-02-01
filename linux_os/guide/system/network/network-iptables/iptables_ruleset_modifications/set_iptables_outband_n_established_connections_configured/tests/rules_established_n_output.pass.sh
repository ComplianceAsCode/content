#!/bin/bash
# platform = multi_platform_all

TABLES_CMDS=("iptables")
IPV6_DISABLED=$(sysctl -n net.ipv6.conf.all.disable_ipv6)

if [ "$IPV6_DISABLED" == "0" ]; then
    TABLES_CMDS+=("ip6tables")
fi

for CMD in "${TABLES_CMDS[@]}"; do
    $CMD -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT
    $CMD -A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT
    $CMD -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT
    $CMD -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT
    $CMD -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT
    $CMD -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT
done
