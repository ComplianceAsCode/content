# platform = multi_platform_all

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

PATTERN="-a always,exit -F path=/var/log/audit/\\s\\+.*"
GROUP="access-audit-trail"
FULL_RULE="-a always,exit -F dir=/var/log/audit/ -F perm=r -F auid>={{{ auid }}} -F auid!=unset -F key=access-audit-trail"
# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
