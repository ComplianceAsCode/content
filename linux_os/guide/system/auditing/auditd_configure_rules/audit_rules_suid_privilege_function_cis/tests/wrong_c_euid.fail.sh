#!/bin/bash
# packages = audit
OTHER_FILTERS_EGID=" -C euid!=gid -F auid!=unset"

echo '-a always,exit -F arch=b32${OTHER_FILTERS_EGID} -S execve -k setuid' > /etc/audit/rules.d/privileged.rules
echo '-a always,exit -F arch=b64${OTHER_FILTERS_EGID} -S execve -k setuid' >> /etc/audit/rules.d/privileged.rules
