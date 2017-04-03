# platform = Red Hat Enterprise Linux 7, multi_platform_fedora

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

# First perform the remediation of the syscall rule
# Retrieve hardware architecture of the underlying system
# Note: 32-bit kernel modules can't be loaded / unloaded on 64-bit kernel =>
#       it's not required on a 64-bit system to check also for the presence
#       of 32-bit's equivalent of the corresponding rule. Therefore for
#       each system it's enought to check presence of system's native rule form.
[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b64")

for ARCH in "${RULE_ARCHS[@]}"
do
	PATTERN="-a always,exit -F arch=$ARCH -S init_module \(-F key=\|-k \).*"
	GROUP="modules"
	FULL_RULE="-a always,exit -F arch=$ARCH -S init_module -k modules"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
	fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
done
