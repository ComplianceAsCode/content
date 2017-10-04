# platform = Red Hat Enterprise Linux 6

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

# Perform the remediation for the syscall rule
# Retrieve hardware architecture of the underlying system
[ $(getconf LONG_BIT) = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

for ARCH in ${RULE_ARCHS[@]}
do
	PATTERN="-a always,exit -F arch=$ARCH -S .* -F auid>=500 -F auid!=4294967295 -k delete"
	# Use escaped BRE regex to specify rule group
	GROUP="\(rmdir\|unlink\|rename\)"
	FULL_RULE="-a always,exit -F arch=$ARCH -S rmdir -S unlink -S unlinkat -S rename -S renameat -F auid>=500 -F auid!=4294967295 -k delete"
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
done
