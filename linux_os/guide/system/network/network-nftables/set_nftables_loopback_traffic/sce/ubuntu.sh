#!/bin/bash
# platform = multi_platform_ubuntu
# check-import = stdout

output=$(nft list ruleset | awk '/hook input/,/}/')
if ! echo "$output" | grep -q 'iif "lo" accept'; then
    exit "${XCCDF_RESULT_FAIL}"
fi

if ! echo "$output" | grep -q 'ip saddr'; then
    exit "${XCCDF_RESULT_FAIL}"
fi

if [ -e /proc/sys/net/ipv6/conf/all/disable_ipv6 ] && [ "$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)" -eq 0 ]; then
    if ! echo "$output" | grep -q 'ip6 saddr'; then
        exit "${XCCDF_RESULT_FAIL}"
    fi
fi

exit "${XCCDF_RESULT_PASS}"
