# platform = Red Hat Virtualization 4,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_almalinux

# Remediation: write audit rules that log all file deletion events
# ('rmdir', 'unlink', 'unlinkat', 'rename', 'renameat', 'renameat2'),
# successful or not. Example output:
#   -a always,exit -F arch=b64 -S unlinkat -F auid>=1000 -F auid!=unset -k delete
#
# On aarch64, 'rmdir', 'unlink', and 'rename' do not exist in the b64
# syscall table and are skipped. The b32 table (for 32-bit programs)
# still has them.
#
# Writes to both '/etc/audit/rules.d/*.rules' (for 'augenrules') and
# '/etc/audit/audit.rules' (for 'auditctl') so the remediation works
# regardless of which tool the system uses to load audit rules.

# Audit rules filter by program type: 32-bit programs use a different
# syscall table than 64-bit programs. On 64-bit systems with a 32-bit
# compatibility layer, both can run, so rules are written for each.
[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

for ARCH in "${RULE_ARCHS[@]}"
do
	ACTION_ARCH_FILTERS="-a always,exit -F arch=$ARCH"
	OTHER_FILTERS=""
	AUID_FILTERS="-F auid>={{{ auid }}} -F auid!=unset"
	KEY="delete"

	# aarch64 b64 syscall table does not have rmdir, unlink, rename;
	# the b32 table (for 32-bit programs, aarch64 can run 32-bit code) still has them
	if [ "$(uname -m)" = "aarch64" ] && [ "$ARCH" = "b64" ]; then
		SYSCALL="unlinkat renameat renameat2"
	else
		SYSCALL="rmdir unlink unlinkat rename renameat renameat2"
	fi
	# SYSCALL_GROUPING tells the macro which syscalls belong together
	# so it merges them into existing rules instead of creating duplicates
	SYSCALL_GROUPING="$SYSCALL"

	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'

	{{{ bash_fix_audit_syscall_rule("augenrules", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
	{{{ bash_fix_audit_syscall_rule("auditctl", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
done
