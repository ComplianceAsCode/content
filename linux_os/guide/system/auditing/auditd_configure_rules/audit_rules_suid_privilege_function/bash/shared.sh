# platform = multi_platform_rhel

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

# First perform the remediation of the syscall rule
# Retrieve hardware architecture of the underlying system
[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

for ARCH in "${RULE_ARCHS[@]}"
do
	ACTION_ARCH_FILTERS="-a always,exit -F arch=$ARCH"
	OTHER_FILTERS="-C uid!=euid -F euid=0"
	AUID_FILTERS=""
	SYSCALL="execve"
	KEY="setuid"
	SYSCALL_GROUPING=""
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	fix_audit_syscall_rule "augenrules" "$ACTION_ARCH_FILTERS" "$OTHER_FILTERS" "$AUID_FILTERS" "$SYSCALL" "$SYSCALL_GROUPING" "$KEY"
	fix_audit_syscall_rule "auditctl" "$ACTION_ARCH_FILTERS" "$OTHER_FILTERS" "$AUID_FILTERS" "$SYSCALL" "$SYSCALL_GROUPING" "$KEY"
done

for ARCH in "${RULE_ARCHS[@]}"
do
	ACTION_ARCH_FILTERS="-a always,exit -F arch=$ARCH"
	OTHER_FILTERS="-C gid!=egid -F egid=0"
	AUID_FILTERS=""
	SYSCALL="execve"
	KEY="setgid"
	SYSCALL_GROUPING=""
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	fix_audit_syscall_rule "augenrules" "$ACTION_ARCH_FILTERS" "$OTHER_FILTERS" "$AUID_FILTERS" "$SYSCALL" "$SYSCALL_GROUPING" "$KEY"
	fix_audit_syscall_rule "auditctl" "$ACTION_ARCH_FILTERS" "$OTHER_FILTERS" "$AUID_FILTERS" "$SYSCALL" "$SYSCALL_GROUPING" "$KEY"
done
