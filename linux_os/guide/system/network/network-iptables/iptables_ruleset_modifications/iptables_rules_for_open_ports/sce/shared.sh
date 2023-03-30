#!/bin/bash
# platform = multi_platform_rhel,multi_platform_ubuntu
# check-import = stdout

result=$XCCDF_RESULT_PASS
iptables_status="$(iptables -L INPUT -v -n)"

while read -r lpn;
do
        if ! grep -Pq "dpt:$lpn" <<< "$iptables_status"; then
                result=$XCCDF_RESULT_FAIL
                break
        fi
done < <(ss -4tuln | awk '($5!~/%lo:/ && $5!~/127.0.0.1:/ && $5!~/::1/) {split($5, a, ":"); print a[2]}i' | sort | uniq)

exit "$result"
