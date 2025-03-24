#!/bin/bash
# packages = audit
{{%- if 'sl' in product %}}
    {{%- set unix_chkpwd_wrong_binary="/usr/sbin/unix_chkpwd" %}}
{{%- else %}}
    {{%- set unix_chkpwd_wrong_binary="/sbin/unix_chkpwd" %}}
{{%- endif %}}
echo "-a always,exit -F path={{{ unix_chkpwd_wrong_binary }}} -F perm=x -F auid>={{{ uid_min }}} -F auid!=unset -F key=privileged" >> /etc/audit/rules.d/privileged.rules
