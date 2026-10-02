#!/bin/bash
# platform = Ubuntu 26.04
# check-import = stdout

if /usr/sbin/sshd -T 2>/dev/null | grep -Piq '^permitemptypasswords\s+no$'; then
    exit "$XCCDF_RESULT_PASS"
fi

echo 'The effective PermitEmptyPasswords value is not no.'
exit "$XCCDF_RESULT_FAIL"
