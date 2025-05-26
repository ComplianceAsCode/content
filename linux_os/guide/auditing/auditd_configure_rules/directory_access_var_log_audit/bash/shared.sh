# platform = multi_platform_all

OTHER_FILTERS="-F dir=/var/log/audit/ -F perm=r"
AUID_FILTERS="-F auid>={{{ auid }}} -F auid!=unset"
SYSCALL=""
KEY="access-audit-trail"
SYSCALL_GROUPING=""
[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

for ARCH in "${RULE_ARCHS[@]}"
do
# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
    ACTION_ARCH_FILTERS="-a always,exit -F arch=$ARCH"
    {{{ bash_fix_audit_syscall_rule("augenrules", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
    {{{ bash_fix_audit_syscall_rule("auditctl", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
done
