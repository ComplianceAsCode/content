# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_ubuntu,multi_platform_debian

# First perform the remediation of the syscall rule
# Retrieve hardware architecture of the underlying system
[ "$(getconf LONG_BIT)" = "32" ] && RULE_ARCHS=("b32") || RULE_ARCHS=("b32" "b64")

for ARCH in "${RULE_ARCHS[@]}"
do
	ACTION_ARCH_FILTERS="-a always,exit -F arch=$ARCH"
	OTHER_FILTERS=""
	AUID_FILTERS=""
	SYSCALL="sethostname setdomainname"
	KEY="audit_rules_networkconfig_modification"
	SYSCALL_GROUPING="sethostname setdomainname"
	# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
	{{{ bash_fix_audit_syscall_rule("augenrules", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
	{{{ bash_fix_audit_syscall_rule("auditctl", "$ACTION_ARCH_FILTERS", "$OTHER_FILTERS", "$AUID_FILTERS", "$SYSCALL", "$SYSCALL_GROUPING", "$KEY") }}}
done

# Then perform the remediations for the watch rules
# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/issue", "wa", "audit_rules_networkconfig_modification") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/issue", "wa", "audit_rules_networkconfig_modification") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/issue.net", "wa", "audit_rules_networkconfig_modification") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/issue.net", "wa", "audit_rules_networkconfig_modification") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/hosts", "wa", "audit_rules_networkconfig_modification") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/hosts", "wa", "audit_rules_networkconfig_modification") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/sysconfig/network", "wa", "audit_rules_networkconfig_modification") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/sysconfig/network", "wa", "audit_rules_networkconfig_modification") }}}
