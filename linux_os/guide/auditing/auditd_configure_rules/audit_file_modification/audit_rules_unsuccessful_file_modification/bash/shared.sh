# platform = Red Hat Virtualization 4,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_almalinux

# Remediation: write audit rules that log only failed file 'open', 'create',
# and 'truncate' attempts -- not successful ones.
# "Failed" means the syscall returned EACCES (permission denied) or
# EPERM (operation not permitted).
#
# For each architecture (b32, b64) and each syscall, two audit rules are
# written -- one for EACCES and one for EPERM -- because auditd cannot
# match multiple exit codes in a single rule. Example output:
#   -a always,exit -F arch=b64 -S openat -F exit=-EACCES -F auid>=1000 -F auid!=unset -k access
#   -a always,exit -F arch=b64 -S openat -F exit=-EPERM  -F auid>=1000 -F auid!=unset -k access
#
# On aarch64, 'creat' and 'open' do not exist in the b64 syscall table
# and are skipped. The b32 table (for 32-bit programs) still has them.
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
	AUID_FILTERS="-F auid>={{{ auid }}} -F auid!=unset"
	KEY="access"

	# aarch64 b64 syscall table does not have creat or open;
	# the b32 table (for 32-bit programs, aarch64 can run 32-bit code) still has them
	if [ "$(uname -m)" = "aarch64" ] && [ "$ARCH" = "b64" ]; then
		SYSCALL="openat open_by_handle_at truncate ftruncate"
	else
		SYSCALL="creat open openat open_by_handle_at truncate ftruncate"
	fi
	# SYSCALL_GROUPING tells the macro which syscalls belong together
	# so it merges them into existing rules instead of creating duplicates
	SYSCALL_GROUPING="$SYSCALL"

	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'

	# First pass: EACCES (permission denied by file mode bits)
	OTHER_FILTERS="-F exit=-EACCES"
	{{{ bash_fix_audit_syscall_rule("augenrules", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
	{{{ bash_fix_audit_syscall_rule("auditctl", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}

	# Second pass: EPERM (operation needs a privilege the process lacks)
	OTHER_FILTERS="-F exit=-EPERM"
	{{{ bash_fix_audit_syscall_rule("augenrules", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
	{{{ bash_fix_audit_syscall_rule("auditctl", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
done
