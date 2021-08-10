# platform = multi_platform_all

PATTERN="-a always,exit -F path=/var/log/audit/\\s\\+.*"
GROUP="access-audit-trail"
FULL_RULE="-a always,exit -F dir=/var/log/audit/ -F perm=r -F auid>={{{ auid }}} -F auid!=unset -F key=access-audit-trail"
# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
{{{ bash_fix_audit_syscall_rule("auditctl", "$PATTERN", "$GROUP", "$ARCH", "$FULL_RULE") }}}
{{{ bash_fix_audit_syscall_rule("augenrules", "$PATTERN", "$GROUP", "$ARCH", "$FULL_RULE") }}}
