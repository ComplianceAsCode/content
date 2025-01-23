#!/bin/bash
# packages = audit

{{%- if product in ["sle15"] %}}
    {{%- set unix2_chkpwd_wrong_binary="/usr/sbin/unix2_chkpwd" %}}
{{%- else %}}
    {{%- set unix2_chkpwd_wrong_binary="/sbin/unix2_chkpwd" %}}
{{%- endif %}}
echo "-a always,exit -F path={{{ unix2_chkpwd_wrong_binary }}} -F perm=x -F auid>={{{ uid_min }}} -F auid!=unset -F key=privileged" >> /etc/audit/rules.d/privileged.rules
