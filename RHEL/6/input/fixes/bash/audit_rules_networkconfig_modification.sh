# Include source function library.
. /usr/share/scap-security-guide/functions

# First perform the remediation of the syscall rule
# Retrieve hardware architecture of the underlying system
[ $(getconf LONG_BIT) = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

for ARCH in ${RULE_ARCHS[@]}
do
	PATTERN="-a always,exit -F arch=$ARCH -S .* -k audit_rules_networkconfig_modification"
	# Use escaped BRE regex to specify rule group
	GROUP="set\(host\|domain\)name"
	FULL_RULE="-a always,exit -F arch=$ARCH -S sethostname -S setdomainname -k audit_rules_networkconfig_modification"
	fix_audit_syscall_rule "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
done

# Then perform the remediations for the watch rules
fix_audit_watch_rule "/etc/issue" "wa" "audit_rules_networkconfig_modification"
fix_audit_watch_rule "/etc/issue.net" "wa" "audit_rules_networkconfig_modification"
fix_audit_watch_rule "/etc/hosts" "wa" "audit_rules_networkconfig_modification"
fix_audit_watch_rule "/etc/sysconfig/network" "wa" "audit_rules_networkconfig_modification"
