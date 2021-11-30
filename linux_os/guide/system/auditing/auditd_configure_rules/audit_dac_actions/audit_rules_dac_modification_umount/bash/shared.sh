# platform = multi_platform_all

ACTION_ARCH_FILTERS="-a always,exit -F arch=b32"
OTHER_FILTERS=""
AUID_FILTERS="-F auid>={{{ auid }}} -F auid!=unset"
SYSCALL="umount"
KEY="perm_mod"
SYSCALL_GROUPING=""

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
{{{ bash_fix_audit_syscall_rule("augenrules", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
{{{ bash_fix_audit_syscall_rule("auditctl", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}

{{% if CHECK_ROOT_USER %}}
	ACTION_ARCH_FILTERS="-a always,exit -F arch=b32"
	OTHER_FILTERS=""
	AUID_FILTERS="-F auid=0"
	SYSCALL="umount"
	KEY="perm_mod"
	SYSCALL_GROUPING=""

	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	{{{ bash_fix_audit_syscall_rule("augenrules", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
	{{{ bash_fix_audit_syscall_rule("auditctl", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
{{% endif %}}
