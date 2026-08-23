#!/bin/bash
# platform = multi_platform_ubuntu
# check-import = stdout

ufw_status="$(ufw status verbose)"

# check ufw is running
if grep -q "Status: inactive" <<< "$ufw_status"; then
    exit $XCCDF_RESULT_FAIL
fi

# check default incoming rule is not allow
if grep -q "Default: allow (incoming)" <<< "$ufw_status"; then
    exit $XCCDF_RESULT_FAIL
fi

# check that listening ports which are open in the firewall are
# not "ALLOW IN", and are thus rate-limited, deny or rejected, or
# or using the default rule
while read -r lpn;
do
    if grep -Pq "^\h*$lpn\b.*ALLOW IN" <<< "$ufw_status"; then
        exit $XCCDF_RESULT_FAIL
    fi
done < <(ss -tulnH | awk '{n=split($5, a, ":"); print a[n]}' | sort -u)

exit $XCCDF_RESULT_PASS
