#!/bin/bash
# platform = Ubuntu 26.04
# check-import = stdout

kex=$(/usr/sbin/sshd -T 2>/dev/null | awk '$1 == "kexalgorithms" { print $2; exit }')
if [[ -n "$kex" ]] && ! grep -Piq '(^|,)(diffie-hellman-group1-sha1|diffie-hellman-group14-sha1|diffie-hellman-group-exchange-sha1)(,|$)' <<< "$kex"; then
    exit "$XCCDF_RESULT_PASS"
fi

echo 'The effective KexAlgorithms list contains a CIS-prohibited SHA-1 algorithm or could not be read.'
exit "$XCCDF_RESULT_FAIL"
