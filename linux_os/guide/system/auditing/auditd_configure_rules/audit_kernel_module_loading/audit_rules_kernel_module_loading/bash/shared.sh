# platform = multi_platform_all

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

# First perform the remediation of the syscall rule
# Retrieve hardware architecture of the underlying system
# Note: 32-bit and 64-bit kernel syscall numbers not always line up =>
#       it's required on a 64-bit system to check also for the presence
#       of 32-bit's equivalent of the corresponding rule.
#       (See `man 7 audit.rules` for details )
[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

for ARCH in "${RULE_ARCHS[@]}"
do
        ACTION_ARCH_FILTERS="-a always,exit -F arch=$ARCH"
        OTHER_FILTERS=""
        AUID_FILTERS=""
        SYSCALL="init_module finit_module delete_module"
        KEY="modules"
        SYSCALL_GROUPING="init_module finit_module delete_module"
        # Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
        fix_audit_syscall_rule "augenrules" "$ACTION_ARCH_FILTERS" "$OTHER_FILTERS" "$AUID_FILTERS" "$SYSCALL" "$SYSCALL_GROUPING" "$KEY"
        fix_audit_syscall_rule "auditctl" "$ACTION_ARCH_FILTERS" "$OTHER_FILTERS" "$AUID_FILTERS" "$SYSCALL" "$SYSCALL_GROUPING" "$KEY"
done
