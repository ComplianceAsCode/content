source fix_audit_syscall_rule.sh

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

	PATTERN="-a always,exit -F arch=${ARCH} -S .* -k *"
	# Create expected audit group and audit rule form for particular system call & architecture
	if [ ${ARCH} = "b32" ]
	then
		# stime system call is known at 32-bit arch (see e.g "$ ausyscall i386 stime" 's output)
		# so append it to the list of time group system calls to be audited
		GROUP="\(adjtimex\|settimeofday\|stime\)"
		FULL_RULE="-a always,exit -F arch=${ARCH} -S adjtimex -S settimeofday -S stime -k audit_time_rules"
	elif [ ${ARCH} = "b64" ]
	then
		# stime system call isn't known at 64-bit arch (see "$ ausyscall x86_64 stime" 's output)
		# therefore don't add it to the list of time group system calls to be audited
		GROUP="\(adjtimex\|settimeofday\)"
		FULL_RULE="-a always,exit -F arch=${ARCH} -S adjtimex -S settimeofday -k audit_time_rules"
	fi
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
done

}
