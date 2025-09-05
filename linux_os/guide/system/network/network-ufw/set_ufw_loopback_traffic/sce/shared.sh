#!/bin/bash
# platform = multi_platform_ubuntu
# check-import = stdout

ufw_status=$(ufw status verbose)

# check in lo
if echo "$ufw_status" | grep -q -P "^Anywhere on lo\s+ALLOW IN\s+Anywhere\b"; then
    exit "${XCCDF_RESULT_FAIL}"
fi

if [ -e /proc/sys/net/ipv6/conf/all/disable_ipv6 ] && [ "$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)" -eq 0 ]; then
    if echo "$ufw_status" | grep -q -P "^Anywhere \(v6\) on lo\s+ALLOW IN\s+Anywhere \(v6\)\b"; then
        exit "${XCCDF_RESULT_FAIL}"
    fi
fi

# check out lo
if echo "$ufw_status" | grep -q -P "^Anywhere\s+ALLOW OUT\s+Anywhere on lo\b"; then
    exit "${XCCDF_RESULT_FAIL}"
fi

if [ -e /proc/sys/net/ipv6/conf/all/disable_ipv6 ] && [ "$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)" -eq 0 ]; then
    if echo "$ufw_status" | grep -P "^Anywhere \(v6\)\s+ALLOW OUT\s+Anywhere \(v6\) on lo\b"; then
        exit "${XCCDF_RESULT_FAIL}"
    fi
fi

# deny in localhost
if echo "$ufw_status" | grep -P "^Anywhere\s+DENY IN\s+127.0.0.0/8\b"; then
    exit "${XCCDF_RESULT_FAIL}"
fi

if [ -e /proc/sys/net/ipv6/conf/all/disable_ipv6 ] && [ "$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)" -eq 0 ]; then
    if echo "$ufw_status" | grep -P "Anywhere \(v6\)\s+DENY IN\s+::1\b"; then
        exit "${XCCDF_RESULT_FAIL}"
    fi
fi

exit "${XCCDF_RESULT_PASS}"
