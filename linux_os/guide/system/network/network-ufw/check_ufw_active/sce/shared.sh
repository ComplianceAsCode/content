#!/usr/bin/env bash
# platform = multi_platform_ubuntu
# check-import = stdout

result=$XCCDF_RESULT_FAIL

if ufw status | grep -qw "active"; then
    result=${XCCDF_RESULT_PASS}
fi

exit $result
