# platform = Red Hat Enterprise Linux 6,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,Red Hat Virtualization 4,multi_platform_ol

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
        GROUP="modules"
{{% if product == "rhel6" %}}
        PATTERN="-a always,exit -F arch=$ARCH -S init_module -S delete_module \(-F key=\|-k \).*"
        FULL_RULE="-a always,exit -F arch=$ARCH -S init_module -S delete_module -k modules"
{{% else %}}
        PATTERN="-a always,exit -F arch=$ARCH -S create_module -S init_module -S delete_module -S finit_module \(-F key=\|-k \).*"
        FULL_RULE="-a always,exit -F arch=$ARCH -S create_module -S delete_module -S init_module -S finit_module -k modules"
{{% endif %}}
        # Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
        fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
        fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
done
