#!/usr/bin/env bash
# platform = multi_platform_all

set +m
shopt -s lastpipe

TABLES_CMDS=("iptables")
PROTOCOLS=("tcp" "udp" "icmp")
CHAINS=("INPUT" "OUTPUT")
IPV6_DISABLED=$(sysctl -n net.ipv6.conf.all.disable_ipv6)

if [ "$IPV6_DISABLED" == "0" ]; then
    TABLES_CMDS+=("ip6tables")
fi

for CMD in "${TABLES_CMDS[@]}"; do
    for CHAIN in "${CHAINS[@]}"; do
        rules_output=$("${CMD}" -L "${CHAIN}" -v -n)

        for PROTO in "${PROTOCOLS[@]}"; do
            rule_state='ESTABLISHED'
            if [ "${CHAIN}" == "OUTPUT" ]; then
                rule_state='NEW,ESTABLISHED'
            fi
            echo "${rules_output}" |grep "${PROTO}"|grep "state ${rule_state}"|grep 'ACCEPT'
            if [ $? -ne 0 ]; then
                exit "${XCCDF_RESULT_FAIL}"
            fi
        done
    done
done

exit "${XCCDF_RESULT_PASS}"
