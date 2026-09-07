#!/bin/bash
# platform = Ubuntu 26.04
# check-import = stdout

if journalctl -q -t sudo -t sudo-rs --since=-5min --no-pager 2>/dev/null |
    grep -q '[^[:space:]]'; then
    exit "$XCCDF_RESULT_PASS"
fi

if grep -Eq '\b(sudo|sudo-rs)\[[0-9]+\]:' /var/log/auth.log 2>/dev/null; then
    exit "$XCCDF_RESULT_PASS"
fi

if ! dpkg-query --show --showformat='${db:Status-Status}' sudo-rs 2>/dev/null |
    grep -qx installed; then
    if grep -rPsiq \
        '^\h*Defaults\h+([^#]+,\h*)?logfile\h*=\h*("|'"'"')?\H+("|'"'"')?(,\h*\H+\h*)*\h*(#.*)?$' \
        /etc/sudoers /etc/sudoers.d 2>/dev/null; then
        exit "$XCCDF_RESULT_PASS"
    fi
fi

echo 'No sudo event was found in the journal or /var/log/auth.log.'
exit "$XCCDF_RESULT_FAIL"
