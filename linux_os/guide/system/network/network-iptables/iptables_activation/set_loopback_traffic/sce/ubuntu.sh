#!/bin/bash
# platform = multi_platform_ubuntu
# check-import = stdout

regex="\s+[0-9]+\s+[0-9]+\s+ACCEPT\s+all\s+--\s+lo\s+\*\s+0\.0\.0\.0\/0\s+0\.0\.0\.0\/0[[:space:]]+[0-9]+\s+[0-9]+\s+DROP\s+all\s+--\s+\*\s+\*\s+127\.0\.0\.0\/8\s+0\.0\.0\.0\/0"

# Check chain INPUT for loopback related rules
if ! iptables -L INPUT -v -n -x | grep -Ezq "$regex" ; then
    exit "$XCCDF_RESULT_FAIL"
fi

# Check chain OUTPUT for loopback related rules
if ! iptables -L OUTPUT -v -n -x | grep -Eq "\s[0-9]+\s+[0-9]+\s+ACCEPT\s+all\s+--\s+\*\s+lo\s+0\.0\.0\.0\/0\s+0\.0\.0\.0\/0" ; then
    exit "$XCCDF_RESULT_FAIL"
fi

exit "$XCCDF_RESULT_PASS"
