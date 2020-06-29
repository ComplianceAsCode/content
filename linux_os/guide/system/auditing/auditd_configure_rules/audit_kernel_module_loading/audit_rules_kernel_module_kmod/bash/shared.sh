# platform = multi_platform_wrlinux,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ol,multi_platform_rhv

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

PATTERN="-w \/usr\/bin\/kmod -p x -F auid!=4294967295 \(-F key=\|-k \).*"
GROUP="modules"
FULL_RULE="-w /usr/bin/kmod -p x -F auid!=4294967295 -k module-change"
# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
fix_audit_syscall_rule "auditctl" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
fix_audit_syscall_rule "augenrules" "$PATTERN" "$GROUP" "$ARCH" "$FULL_RULE"
