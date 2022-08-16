# platform = multi_platform_rhel

ACTION_ARCH_FILTERS=""
OTHER_FILTERS="-w /usr/bin/kmod -p x"
AUID_FILTERS="-F auid!=unset"
SYSCALL=""
KEY="module-change"
SYSCALL_GROUPING="{{{ SYSCALL_GROUPING }}}"
# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
{{{ bash_fix_audit_syscall_rule("augenrules", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
{{{ bash_fix_audit_syscall_rule("auditctl", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
