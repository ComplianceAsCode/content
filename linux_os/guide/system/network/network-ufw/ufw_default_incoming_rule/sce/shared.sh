#!/usr/bin/env bash
# platform = multi_platform_ubuntu,multi_platform_debian
# check-import = stdout

result=$XCCDF_RESULT_FAIL

ufw_default_line=$(ufw status verbose 2>/dev/null | grep "^Default:")

if echo "$ufw_default_line" | grep -Eq "(deny|reject|disabled) \(incoming\)"; then
    result=${XCCDF_RESULT_PASS}
fi

exit $result
