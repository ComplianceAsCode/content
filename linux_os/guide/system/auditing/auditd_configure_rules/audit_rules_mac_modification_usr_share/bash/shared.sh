# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_rhv,multi_platform_sle,multi_platform_ubuntu

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
{{{ bash_fix_audit_watch_rule("auditctl", "/usr/share/selinux/", "wa", "MAC-policy") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/usr/share/selinux/", "wa", "MAC-policy") }}}
