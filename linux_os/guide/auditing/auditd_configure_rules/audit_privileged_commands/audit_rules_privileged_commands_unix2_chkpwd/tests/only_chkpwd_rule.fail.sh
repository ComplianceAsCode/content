#!/bin/bash
# packages = audit

# in SLE the default place to check for the unix2_chkpwd binary as defined in STIG is /sbin/
# whereas in other products they check in /usr/sbin. They are technically the same, but the OVAL
# check will look for specific directories according to the product. Here for the sake of the
# test scenario setup we invert the binaries so the OVAL fails the check on purpose.
{{%- if product in ["sle15"] %}}
    {{%- set unix2_chkpwd_wrong_binary="/usr/sbin/unix2_chkpwd" %}}
{{%- else %}}
    {{%- set unix2_chkpwd_wrong_binary="/sbin/unix2_chkpwd" %}}
{{%- endif %}}
echo "-a always,exit -F path={{{ unix2_chkpwd_wrong_binary }}} -F perm=x -F auid>={{{ uid_min }}} -F auid!=unset -F key=privileged" >> /etc/audit/rules.d/privileged.rules
