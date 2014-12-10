# Include source function library.
. /usr/share/scap-security-guide/functions

# First perform the remediation of the syscall rule
# Retrieve hardware architecture of the underlying system
# Note: 32-bit kernel modules can't be loaded / unloaded on 64-bit kernel =>
#       it's not required on a 64-bit system to check also for the presence
#       of 32-bit's equivalent of the corresponding rule. Therefore for
#       each system it's enought to check presence of system's native rule form.
[ $(getconf LONG_BIT) = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b64")

for ARCH in ${RULE_ARCHS[@]}
do
	PATTERN="-a always,exit -F arch=$ARCH -S .* -k modules"
	# Use escaped BRE regex to specify rule group
	GROUP="\(init\|delete\)_module"
	FULL_RULE="-a always,exit -F arch=$ARCH -S init_module -S delete_module -k modules"
	fix_audit_syscall_rule "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
done

# Then perform the remediations for the watch rules
fix_audit_watch_rule "/sbin/insmod" "x" "modules"
fix_audit_watch_rule "/sbin/rmmod" "x" "modules"
fix_audit_watch_rule "/sbin/modprobe" "x" "modules"
