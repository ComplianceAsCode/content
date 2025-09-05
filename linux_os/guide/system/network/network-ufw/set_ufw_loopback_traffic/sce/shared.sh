#!/bin/bash
# platform = multi_platform_ubuntu
# check-import = stdout

ufw_status=$(ufw status verbose)

# check in lo
if ! grep -q -E "^Anywhere on lo\s+ALLOW IN\s+Anywhere" <<< "$ufw_status"; then
    exit "${XCCDF_RESULT_FAIL}"
fi

if [ -e /proc/sys/net/ipv6/conf/all/disable_ipv6 ] && [ "$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)" -eq 0 ]; then
    if ! grep -q -E "^Anywhere \(v6\) on lo\s+ALLOW IN\s+Anywhere \(v6\)" <<< "$ufw_status"; then
        exit "${XCCDF_RESULT_FAIL}"
    fi
fi

# check out lo
if ! grep -q -E "^Anywhere\s+ALLOW OUT\s+Anywhere on lo" <<< "$ufw_status"; then
    exit "${XCCDF_RESULT_FAIL}"
fi

if [ -e /proc/sys/net/ipv6/conf/all/disable_ipv6 ] && [ "$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)" -eq 0 ]; then
    if ! grep -q -E "^Anywhere \(v6\)\s+ALLOW OUT\s+Anywhere \(v6\) on lo" <<< "$ufw_status"; then
        exit "${XCCDF_RESULT_FAIL}"
    fi
fi

# deny in localhost
if ! grep -q -E "^Anywhere\s+DENY IN\s+127.0.0.0/8" <<< "$ufw_status"; then
    exit "${XCCDF_RESULT_FAIL}"
fi

if [ -e /proc/sys/net/ipv6/conf/all/disable_ipv6 ] && [ "$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)" -eq 0 ]; then
    if ! grep -q -E "Anywhere \(v6\)\s+DENY IN\s+::1" <<< "$ufw_status"; then
        exit "${XCCDF_RESULT_FAIL}"
    fi
fi

exit "${XCCDF_RESULT_PASS}"
