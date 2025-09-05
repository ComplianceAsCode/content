#!/bin/bash
# platform = multi_platform_ubuntu
# check-import = stdout

# Pass rule if IPv6 is disabled on kernel
if [ ! -e /proc/sys/net/ipv6/conf/all/disable_ipv6 ] || [ "$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)" -eq 1 ]; then
    exit "$XCCDF_RESULT_PASS"
fi

output="$(ip6tables -L | grep Chain)"
if [ -z "${output}" ]; then
    exit "$XCCDF_RESULT_FAIL"
fi

while read -r line; do
    chain=$(echo "$line" | awk '{print $1, $2}')
    policy=$(echo "$line" | awk '{print $4}' | tr -d ")")
    if [ "$chain" = "Chain INPUT" ] || [ "$chain" = "Chain FORWARD" ] ||
       [ "$chain" = "Chain OUTPUT" ]; then
        if [ "$policy" != "DROP" ] && [ "$policy" != "REJECT" ]; then
            exit "$XCCDF_RESULT_FAIL"
        fi
    fi
done <<< "$output"

exit "$XCCDF_RESULT_PASS"
