# platform = Red Hat Enterprise Linux 6

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

# First perform the remediation of the syscall rule
# Retrieve hardware architecture of the underlying system
# If the system has a 32-bit processor, only the 32-bit rule is needed.
# If the system has a 64-bit processor, both arch 32 and 64 need to be included in
# the audit file because it is not possible to know if the computer will be booted
# in 64 or 32 bit mode or for which architecture a binary is compiled.
[ $(getconf LONG_BIT) = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

for ARCH in "${RULE_ARCHS[@]}"
do
	PATTERN="-a always,exit -F arch=$ARCH -S .* -k *"
	# Use escaped BRE regex to specify rule group
	GROUP="\(init\|delete\)_module"
	FULL_RULE="-a always,exit -F arch=$ARCH -S init_module -S delete_module -k modules"
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
done

# Then perform the remediations for the watch rules
fix_audit_watch_rule "auditctl" "/sbin/insmod" "x" "modules"
fix_audit_watch_rule "auditctl" "/sbin/rmmod" "x" "modules"
fix_audit_watch_rule "auditctl" "/sbin/modprobe" "x" "modules"
