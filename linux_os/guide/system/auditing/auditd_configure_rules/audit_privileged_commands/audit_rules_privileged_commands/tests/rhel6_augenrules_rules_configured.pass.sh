#!/bin/bash
# remediation = bash
# platform = Red Hat Enterprise Linux 6

./generate_privileged_commands_rule.sh 500 privileged /etc/audit/rules.d/privileged.rules
sed -i "s/USE_AUGENRULES=.*/USE_AUGENRULES=\"yes\"/" /etc/sysconfig/auditd
