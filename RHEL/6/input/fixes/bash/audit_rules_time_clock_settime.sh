# Include source function library.
. /usr/share/scap-security-guide/functions

# First perform the remediation of the syscall rule
# Retrieve hardware architecture of the underlying system
[ $(getconf LONG_BIT) = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

for ARCH in ${RULE_ARCHS[@]}
do
	PATTERN="-a always,exit -F arch=$ARCH -S .* -k audit_time_rules"
	GROUP="clock_settime"
	FULL_RULE="-a always,exit -F arch=$ARCH -S clock_settime -k audit_time_rules"
	fix_audit_syscall_rule "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
done
