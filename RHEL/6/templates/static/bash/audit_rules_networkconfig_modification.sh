# platform = Red Hat Enterprise Linux 6

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

# First perform the remediation of the syscall rule
# Retrieve hardware architecture of the underlying system
[ $(getconf LONG_BIT) = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

for ARCH in "${RULE_ARCHS[@]}"
do
	PATTERN="-a always,exit -F arch=$ARCH -S .* -k *"
	# Use escaped BRE regex to specify rule group
	GROUP="set\(host\|domain\)name"
	FULL_RULE="-a always,exit -F arch=$ARCH -S sethostname -S setdomainname -k audit_rules_networkconfig_modification"
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
done

# Then perform the remediations for the watch rules
fix_audit_watch_rule "auditctl" "/etc/issue" "wa" "audit_rules_networkconfig_modification"
fix_audit_watch_rule "auditctl" "/etc/issue.net" "wa" "audit_rules_networkconfig_modification"
fix_audit_watch_rule "auditctl" "/etc/hosts" "wa" "audit_rules_networkconfig_modification"
fix_audit_watch_rule "auditctl" "/etc/sysconfig/network" "wa" "audit_rules_networkconfig_modification"
