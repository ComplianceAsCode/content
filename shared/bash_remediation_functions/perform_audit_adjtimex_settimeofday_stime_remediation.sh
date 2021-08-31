# Function to perform remediation for the 'adjtimex', 'settimeofday', and 'stime' audit
# system calls on RHEL, Fedora or OL systems.
# Remediation performed for both possible tools: 'auditctl' and 'augenrules'.
#
# Note: 'stime' system call isn't known at 64-bit arch (see "$ ausyscall x86_64 stime" 's output)
# therefore excluded from the list of time group system calls to be audited on this arch
#
# Example Call:
#
#      perform_audit_adjtimex_settimeofday_stime_remediation
#
function perform_audit_adjtimex_settimeofday_stime_remediation {

# Retrieve hardware architecture of the underlying system
[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

for ARCH in "${RULE_ARCHS[@]}"
do

	# Create expected audit group and audit rule form for particular system call & architecture
	if [ ${ARCH} = "b32" ]
	then
		ACTION_ARCH_FILTERS="-a always,exit -F arch=$ARCH"
		# stime system call is known at 32-bit arch (see e.g "$ ausyscall i386 stime" 's output)
		# so append it to the list of time group system calls to be audited
		SYSCALL="adjtimex settimeofday stime"
		SYSCALL_GROUPING="adjtimex settimeofday stime"
	elif [ ${ARCH} = "b64" ]
	then
		ACTION_ARCH_FILTERS="-a always,exit -F arch=$ARCH"
		# stime system call isn't known at 64-bit arch (see "$ ausyscall x86_64 stime" 's output)
		# therefore don't add it to the list of time group system calls to be audited
		SYSCALL="adjtimex settimeofday"
		SYSCALL_GROUPING="adjtimex settimeofday"
	fi
	OTHER_FILTERS=""
	AUID_FILTERS=""
	KEY="audit_time_rules"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	{{{ bash_fix_audit_syscall_rule("augenrules", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
	{{{ bash_fix_audit_syscall_rule("auditctl", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
done

}
