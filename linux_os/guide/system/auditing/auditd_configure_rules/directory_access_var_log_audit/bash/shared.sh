# platform = multi_platform_all

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

ACTION_ARCH_FILTERS="-a always,exit"
OTHER_FILTERS="-F dir=/var/log/audit/ -F perm=r"
AUID_FILTERS="-F auid>={{{ auid }}} -F auid!=unset"
SYSCALL=""
KEY="access-audit-trail"
SYSCALL_GROUPING=""
# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
fix_audit_syscall_rule "augenrules" "$ACTION_ARCH_FILTERS" "$OTHER_FILTERS" "$AUID_FILTERS" "$SYSCALL" "$SYSCALL_GROUPING" "$KEY"
fix_audit_syscall_rule "auditctl" "$ACTION_ARCH_FILTERS" "$OTHER_FILTERS" "$AUID_FILTERS" "$SYSCALL" "$SYSCALL_GROUPING" "$KEY"
