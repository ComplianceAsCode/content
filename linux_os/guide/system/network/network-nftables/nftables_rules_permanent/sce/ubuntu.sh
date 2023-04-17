#!/bin/bash
# platform = multi_platform_ubuntu
# check-import = stdout

# Check rules in input chain
filename="/etc/nftables.conf"

in_regexp="chain input {[^}]+}"
grep -Ezo "${in_regexp}" ${filename} | grep -Ezqw "policy drop" &&\
    grep -Ezo "${in_regexp}" ${filename} | grep -Ezqw "iif \"lo\" accept" &&\
    grep -Ezo "${in_regexp}" ${filename} | grep -Ezqw "ip saddr 127.0.0.0/8"
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

# Only verify IPv6 rules if IPv6 support is enabled
if [ -e /proc/sys/net/ipv6/conf/all/disable_ipv6 ] && [ "$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)" -eq 0 ]; then
    grep -Ezo "${in_regexp}" ${filename} | grep -Ezqw "ip6 saddr ::1"
    if [ $? -ne 0 ]; then
        exit ${XCCDF_RESULT_FAIL}
    fi
fi

out_regexp="chain output {[^}]+}"
grep -Ezo "${out_regexp}" ${filename} | grep -Ezqw "policy drop"
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

fwd_regexp="chain forward {[^}]+}"
grep -Ezo "${fwd_regexp}" ${filename} | grep -Ezqw "policy drop"
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

exit ${XCCDF_RESULT_PASS}
