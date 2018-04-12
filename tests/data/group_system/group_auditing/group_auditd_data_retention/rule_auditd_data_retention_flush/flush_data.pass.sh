#!/bin/bash
# profiles = profile_not_found

yum install -y audit

FLUSH_REGEX="^flush[[:space:]]*=.*$"
if grep -q "$FLUSH_REGEX" /etc/audit/auditd.conf; then
        sed -i "s/$FLUSH_REGEX/flush = data/" /etc/audit/auditd.conf
else
        echo "flush = data" >> /etc/audit/auditd.conf
fi
