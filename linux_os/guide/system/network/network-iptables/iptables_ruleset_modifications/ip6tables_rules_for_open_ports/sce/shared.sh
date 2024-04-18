#!/bin/bash
# platform = multi_platform_rhel,multi_platform_ubuntu
# check-import = stdout

result=$XCCDF_RESULT_PASS
iptables_status="$(ip6tables -L INPUT -v -n)"

while read -r lpn;
do
        if ! grep -Pq "dpt:$lpn" <<< "$iptables_status"; then
                result=$XCCDF_RESULT_FAIL
                break
        fi
    done < <(ss -6tulnH | awk '($5!~/::1/) {n=split($5, a, ":"); print a[n]}' | sort -u)

exit "$result"
