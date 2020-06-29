# platform = Red Hat Virtualization 4,multi_platform_ol,multi_platform_rhel

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

# Perform the remediation for the syscall rule
# Retrieve hardware architecture of the underlying system
[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

for ARCH in "${RULE_ARCHS[@]}"
do
	PATTERN="-a always,exit -F arch=$ARCH -S execve -C uid!=euid -F euid=0 -k setuid"
	# Use escaped BRE regex to specify rule group
	GROUP="execve"
	FULL_RULE="-a always,exit -F arch=$ARCH -S execve -C uid!=euid -F euid=0 -k setuid"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"

	PATTERN="-a always,exit -F arch=$ARCH -S execve -C gid!=egid -F egid=0 -k setgid"
	# Use escaped BRE regex to specify rule group
	GROUP="execve"
	FULL_RULE="-a always,exit -F arch=$ARCH -S execve -C gid!=egid -F egid=0 -k setgid"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
done
