#!/bin/bash
# packages = audit

# The OVAL check treats a trailing slash on the watched path as optional.
# Toggle the trailing slash relative to the rule's configured path and confirm
# the check still passes.
if [[ "$path" == */ ]]; then toggled_path="${path%/}"; else toggled_path="${path}/"; fi

if [[ "$style" == "modern" ]] ; then
    echo "-a always,exit -F arch=b32 -F $filter_type=$toggled_path -F perm=wa -F key=logins" >> /etc/audit/audit.rules
    echo "-a always,exit -F arch=b64 -F $filter_type=$toggled_path -F perm=wa -F key=logins" >> /etc/audit/audit.rules
else
    echo "-w $toggled_path -p wa -k login" >> /etc/audit/audit.rules
fi
