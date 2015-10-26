# platform = Red Hat Enterprise Linux 7

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

# Perform the remediation for the syscall rule
# Retrieve hardware architecture of the underlying system
[ $(getconf LONG_BIT) = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

for ARCH in "${RULE_ARCHS[@]}"
do
	PATTERN="-a always,exit -F arch=$ARCH -S .* -F auid>=1000 -F auid!=4294967295 -k *"
	GROUP="chmod"
	FULL_RULE="-a always,exit -F arch=$ARCH -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
done
