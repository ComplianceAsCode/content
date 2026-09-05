#!/bin/bash
# platform = Ubuntu 26.04
# check-import = stdout

value=$(/usr/sbin/sshd -T 2>/dev/null | awk '$1 == "clientalivecountmax" { print $2; exit }')
if [[ "$value" =~ ^[0-9]+$ ]] && (( value > 0 )); then
    exit "$XCCDF_RESULT_PASS"
fi

echo "The effective ClientAliveCountMax value is '${value:-unavailable}', not greater than zero."
exit "$XCCDF_RESULT_FAIL"
