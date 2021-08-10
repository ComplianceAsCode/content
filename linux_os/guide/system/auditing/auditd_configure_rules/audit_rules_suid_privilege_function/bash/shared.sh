# platform = multi_platform_rhel

# First perform the remediation of the syscall rule
# Retrieve hardware architecture of the underlying system
[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

for ARCH in "${RULE_ARCHS[@]}"
do
	PATTERN="-a always,exit -F arch=$ARCH -S execve -C uid!=euid -F euid=0"
	GROUP="privileged"
	FULL_RULE="-a always,exit -F arch=$ARCH -S execve -C uid!=euid -F euid=0 -k setuid"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	{{{ bash_fix_audit_syscall_rule("auditctl", "$PATTERN", "$GROUP", "$ARCH", "$FULL_RULE") }}}
	{{{ bash_fix_audit_syscall_rule("augenrules", "$PATTERN", "$GROUP", "$ARCH", "$FULL_RULE") }}}
done

for ARCH in "${RULE_ARCHS[@]}"
do
	PATTERN="-a always,exit -F arch=$ARCH -S execve -C gid!=egid -F egid=0"
	GROUP="privileged"
	FULL_RULE="-a always,exit -F arch=$ARCH -S execve -C gid!=egid -F egid=0 -k setgid"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	{{{ bash_fix_audit_syscall_rule("auditctl", "$PATTERN", "$GROUP", "$ARCH", "$FULL_RULE") }}}
	{{{ bash_fix_audit_syscall_rule("augenrules", "$PATTERN", "$GROUP", "$ARCH", "$FULL_RULE") }}}
done
