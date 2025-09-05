# platform = Red Hat Virtualization 4,multi_platform_ol,multi_platform_rhel,multi_platform_sle

# Perform the remediation of the syscall rule
# Retrieve hardware architecture of the underlying system
[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

for ARCH in "${RULE_ARCHS[@]}"
do

	# First fix the -EACCES requirement
	ACTION_ARCH_FILTERS="-a always,exit -F arch=$ARCH"
	OTHER_FILTERS="-F exit=-EACCES"
	AUID_FILTERS="-F auid>={{{ auid }}} -F auid!=unset"
	SYSCALL="creat open openat open_by_handle_at truncate ftruncate"
	KEY="access"
	SYSCALL_GROUPING="creat open openat open_by_handle_at truncate ftruncate"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	{{{ bash_fix_audit_syscall_rule("augenrules", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
	{{{ bash_fix_audit_syscall_rule("auditctl", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}

	# Then fix the -EPERM requirement
	# No need to change content of $GROUP variable - it's the same as for -EACCES case above
	ACTION_ARCH_FILTERS="-a always,exit -F arch=$ARCH"
	OTHER_FILTERS="-F exit=-EPERM"
	AUID_FILTERS="-F auid>={{{ auid }}} -F auid!=unset"
	SYSCALL="creat open openat open_by_handle_at truncate ftruncate"
	KEY="access"
	SYSCALL_GROUPING="creat open openat open_by_handle_at truncate ftruncate"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	{{{ bash_fix_audit_syscall_rule("augenrules", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
	{{{ bash_fix_audit_syscall_rule("auditctl", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}

done
