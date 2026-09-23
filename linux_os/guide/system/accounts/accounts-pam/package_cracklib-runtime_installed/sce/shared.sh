#!/bin/bash
# platform = Ubuntu 26.04
# check-import = stdout

if ! dpkg-query -W -f='${db:Status-Status}\n' cracklib-runtime 2>/dev/null | grep -qx installed; then
    echo 'cracklib-runtime is not installed.'
    exit "$XCCDF_RESULT_FAIL"
fi

if apt list --upgradable 2>/dev/null | grep -Pq '^cracklib-runtime/'; then
    echo 'An upgrade is available for cracklib-runtime.'
    exit "$XCCDF_RESULT_FAIL"
fi

exit "$XCCDF_RESULT_PASS"
