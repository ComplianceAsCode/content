#!/bin/bash
# platform = multi_platform_ubuntu
# check-import = stdout

output=$(nft list ruleset | awk '/hook input/,/}/')
if ! grep 'iif "lo" accept' "$output"; then
    exit "${XCCDF_RESULT_FAIL}"
fi

if ! grep 'ip saddr' "$output"; then
    exit "${XCCDF_RESULT_FAIL}"
fi

if [ -e /proc/sys/net/ipv6/conf/all/disable_ipv6 ] && [ "$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)" -eq 0 ]; then
    if ! grep 'ip6 saddr' "$output"; then
        exit "${XCCDF_RESULT_FAIL}"
    fi
fi

exit "${XCCDF_RESULT_PASS}"
