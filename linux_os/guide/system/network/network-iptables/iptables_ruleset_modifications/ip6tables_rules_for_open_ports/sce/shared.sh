#!/bin/bash
# platform = multi_platform_rhel,multi_platform_ubuntu
# check-import = stdout

result=$XCCDF_RESULT_PASS

# Pass rule if IPv6 is disabled on kernel
if [ ! -e /proc/sys/net/ipv6/conf/all/disable_ipv6 ] || [ "$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)" -eq 1 ]; then
    exit "$XCCDF_RESULT_PASS"
fi

iptables_status="$(ip6tables -S INPUT -v)"
while read -r proto port;
do
    if ! grep -Piq " \-p $proto .* \-\-dport(s)? [0-9,]*\b$port\b" <<< "$iptables_status"; then
        result=$XCCDF_RESULT_FAIL
        break
    fi
done < <(ss -6tulnH | awk '($5!~/::1/) {n=split($5, a, ":"); print $1, a[n]}' | sort -u)

exit $result
