# platform = multi_platform_rhel

[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

for ARCH in "${RULE_ARCHS[@]}"
do
    ACTION_ARCH_FILTERS="-a always,exit -F arch=$ARCH"
    SYSCALL="execve"
    KEY="cron_exec"

    # euid=0 rules
    OTHER_FILTERS="-F subj_type=crond_t -F euid=0"
    AUID_FILTERS=""
    SYSCALL_GROUPING=""
    {{{ bash_fix_audit_syscall_rule("augenrules", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
    {{{ bash_fix_audit_syscall_rule("auditctl", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}

    # auid>={{{ uid_min }}} rules
    OTHER_FILTERS="-F subj_type=crond_t"
    AUID_FILTERS="-F auid>={{{ uid_min }}} -F auid!=unset"
    {{{ bash_fix_audit_syscall_rule("augenrules", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
    {{{ bash_fix_audit_syscall_rule("auditctl", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
done
