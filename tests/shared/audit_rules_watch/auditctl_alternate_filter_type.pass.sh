#!/bin/bash
# packages = audit

# The OVAL check accepts either the 'dir=' (subtree) or 'path=' (single object)
# filter type. Configure the rule using the opposite filter type from the one
# the remediation would emit and confirm the check still passes.
if [[ "$style" == "modern" ]] ; then
    if [[ "$filter_type" == "dir" ]]; then alt_filter="path"; else alt_filter="dir"; fi
    echo "-a always,exit -F arch=b32 -F $alt_filter=$path -F perm=wa -F key=logins" >> /etc/audit/audit.rules
    echo "-a always,exit -F arch=b64 -F $alt_filter=$path -F perm=wa -F key=logins" >> /etc/audit/audit.rules
else
    # Legacy '-w' watches have no dir/path distinction; use the standard form.
    echo "-w $path -p wa -k login" >> /etc/audit/audit.rules
fi
