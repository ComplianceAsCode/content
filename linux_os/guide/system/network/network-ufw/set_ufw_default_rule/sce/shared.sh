#!/bin/bash
# platform = multi_platform_ubuntu,multi_platform_debian
# check-import = stdout

default_status=$(ufw status verbose | grep "Default:")

count=$(echo "$default_status" | grep -oP "(deny|reject|disabled) \((incoming|outgoing|routed)\)" | wc -l)

if [ "$count" -ne 3 ]; then
    exit "$XCCDF_RESULT_FAIL"
fi

exit "$XCCDF_RESULT_PASS"
